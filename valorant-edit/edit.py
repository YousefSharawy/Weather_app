"""Beat-synced Valorant edit renderer.

Rebuilds the structure of the reference edit (see STYLE_GUIDE.md) with new clips:
kills land on the reference's beat grid, with whip-blur cuts, flashes, speed lines,
RGB split, lyric text, a freeze before the final kill, and a crush-to-black ending.

Usage:
  python edit.py --kills kills.json --song reference.mp4 --out edit.mp4 [--aspect 9:16] [--handle @me]

kills.json:
  {"showcase": [{"clip": "clips/a.mp4", "start": 3.0}],        # slow knife/skin shots (intro + breather)
   "kills":    [{"clip": "clips/b.mp4", "t": 12.4, "score": 5}]} # t = moment the kill registers (s)
"""
import argparse, json, math, os, random, shutil, subprocess, sys
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

FPS = 30
HERE = os.path.dirname(os.path.abspath(__file__))

# Timing map measured from the reference (seconds). Same song -> same grid.
INTRO = (0.0, 3.97)
DROP1 = (3.97, 4.70)
BREATHER = (4.70, 7.00)
MONTAGE_CUTS = [7.00, 8.00, 8.70, 9.20, 9.43, 10.17, 10.67, 11.17, 11.40, 11.90, 12.27, 12.67,
                13.13, 13.40, 13.67, 14.23, 14.60, 14.83, 15.33, 15.87, 16.33, 16.83, 17.27, 17.80,
                18.27, 18.77, 19.23, 19.70, 20.23, 20.73, 21.17, 21.70, 22.13, 22.63]
FREEZE = (22.63, 23.67)
FINAL_END = 24.50
CRUSH = (24.00, 24.50)
OUTRO = (24.50, 28.60)
FLASHES = [(4.00, 2), (7.00, 3)]  # (time, frames)
SPEED_LINES = [(7.0, 15.0), (18.8, 20.7)]
KILL_LEAD = 2  # kill shows this many frames after the cut (reference: 1-3)


def F(t):
    return int(round(t * FPS))


# ---------------------------------------------------------------- video access
class Clip:
    cache = {}

    def __init__(self, path):
        self.path = path
        cap = cv2.VideoCapture(path)
        if not cap.isOpened():
            sys.exit(f"cannot open {path}")
        self.fps = cap.get(cv2.CAP_PROP_FPS) or 30
        self.n = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        self.cap = cap
        self.pos = -1
        self.last = None

    @classmethod
    def get(cls, path):
        if path not in cls.cache:
            cls.cache[path] = Clip(path)
        return cls.cache[path]

    def at(self, t):
        i = max(0, min(self.n - 1, int(round(t * self.fps))))
        if i != self.pos + 1:
            if i == self.pos and self.last is not None:
                return self.last
            self.cap.set(cv2.CAP_PROP_POS_FRAMES, i)
        ok, f = self.cap.read()
        if not ok:
            return self.last if self.last is not None else np.zeros((720, 1280, 3), np.uint8)
        self.pos, self.last = i, f
        return f

    @property
    def dur(self):
        return self.n / self.fps


# ---------------------------------------------------------------- effects
def cover(img, W, H):
    h, w = img.shape[:2]
    s = max(W / w, H / h)
    img = cv2.resize(img, (math.ceil(w * s), math.ceil(h * s)), interpolation=cv2.INTER_LINEAR)
    y, x = (img.shape[0] - H) // 2, (img.shape[1] - W) // 2
    return img[y:y + H, x:x + W]


def grade(img):
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV).astype(np.float32)
    hsv[..., 1] = np.clip(hsv[..., 1] * 1.4, 0, 255)
    img = cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR).astype(np.float32)
    img = (img - 128) * 1.15 + 128
    blur = cv2.GaussianBlur(img, (0, 0), 2)
    img = img + 0.6 * (img - blur)
    return np.clip(img, 0, 255).astype(np.uint8)


def zoom(img, s, cx=0.5, cy=0.5):
    if abs(s - 1) < 1e-3:
        return img
    H, W = img.shape[:2]
    M = cv2.getRotationMatrix2D((W * cx, H * cy), 0, s)
    return cv2.warpAffine(img, M, (W, H), borderMode=cv2.BORDER_REFLECT)


def motion_blur(img, length, angle):
    length = int(length)
    if length < 3:
        return img
    k = np.zeros((length, length), np.float32)
    k[length // 2, :] = 1
    M = cv2.getRotationMatrix2D((length / 2 - 0.5, length / 2 - 0.5), angle, 1)
    k = cv2.warpAffine(k, M, (length, length))
    k /= k.sum()
    return cv2.filter2D(img, -1, k)


def whip(img, strength, angle, shift):
    H, W = img.shape[:2]
    rad = math.radians(angle)
    M = np.float32([[1, 0, math.cos(rad) * shift * W], [0, 1, math.sin(rad) * shift * H]])
    img = cv2.warpAffine(img, M, (W, H), borderMode=cv2.BORDER_REFLECT)
    return motion_blur(img, strength * W * 0.12, angle)


def radial_blur(img, amount):
    acc = img.astype(np.float32)
    n = 8
    for i in range(1, n):
        acc += zoom(img, 1 + amount * i / n).astype(np.float32)
    return (acc / n).astype(np.uint8)


def rgb_split(img, px):
    px = int(px)
    if px < 1:
        return img
    b, g, r = cv2.split(img)
    r = np.roll(r, px, axis=1)
    b = np.roll(b, -px, axis=1)
    return cv2.merge([b, g, r])


def flash(img, a):
    return cv2.addWeighted(img, 1 - a, np.full_like(img, 255), a, 0)


def levels_crush(img, p):
    """p=0 untouched, p=1 black. Shadows vanish first (like the reference)."""
    lo = 255 * p
    f = (img.astype(np.float32) - lo) / max(1.0, 255 - lo) * 255 * (1 - p * 0.6)
    return np.clip(f, 0, 255).astype(np.uint8)


class SpeedLines:
    def __init__(self, W, H, seed=1):
        self.W, self.H = W, H
        self.rng = random.Random(seed)

    def draw(self, img):
        ov = img.copy()
        for _ in range(14):
            y = self.rng.randint(0, self.H)
            x = self.rng.randint(-self.W // 2, self.W)
            L = self.rng.randint(self.W // 6, self.W // 2)
            cv2.line(ov, (x, y), (x + L, y), (255, 255, 255), self.rng.choice([1, 1, 2]), cv2.LINE_AA)
        return cv2.addWeighted(img, 0.55, ov, 0.45, 0)


def red_frame(img, t):
    """Drop-1 look: gameplay shrinks into a glowing red frame on a red vignette."""
    H, W = img.shape[:2]
    s = 0.80 + 0.04 * math.exp(-t * 6)
    bg = np.zeros_like(img)
    bg[:] = (20, 10, 150)
    yy, xx = np.mgrid[0:H, 0:W]
    d = np.sqrt(((xx - W / 2) / W) ** 2 + ((yy - H / 2) / H) ** 2)
    bg = (bg * np.clip(1.3 - d * 1.6, 0.2, 1)[..., None]).astype(np.uint8)
    w, h = int(W * s), int(H * s)
    small = cv2.resize(img, (w, h))
    x0, y0 = (W - w) // 2, (H - h) // 2
    glow = np.zeros_like(img)
    cv2.rectangle(glow, (x0, y0), (x0 + w, y0 + h), (60, 60, 255), max(6, W // 120))
    glow = cv2.GaussianBlur(glow, (0, 0), W / 90)
    out = cv2.add(bg, glow)
    out[y0:y0 + h, x0:x0 + w] = small
    cv2.rectangle(out, (x0, y0), (x0 + w, y0 + h), (200, 200, 255), max(2, W // 400))
    return out


# ---------------------------------------------------------------- text
FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Impact.ttf",          # macOS
    "/Library/Fonts/Impact.ttf",
    "/System/Library/Fonts/Supplemental/Arial Black.ttf",
    "C:/Windows/Fonts/impact.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",   # Linux fallback
]
FONT = next((f for f in FONT_CANDIDATES if os.path.exists(f)), None)
if FONT is None:
    sys.exit("no bold font found; edit FONT_CANDIDATES in edit.py")
CONDENSE = 1.0 if "mpact" in FONT else 0.72  # Impact is already condensed


def text_layer(W, H, word, style, t_in):
    """Letter-by-letter reveal; returns (rgba np array)."""
    size = int(H * (0.30 if style == "red" else 0.42))
    font = ImageFont.truetype(FONT, size)
    n = min(len(word), int(t_in * FPS / 2.5) + 1)  # one letter every 2.5 frames
    shown = word[:n]
    tw = int(font.getlength(word))
    canvas = Image.new("RGBA", (tw + size, int(size * 1.5)), (0, 0, 0, 0))
    d = ImageDraw.Draw(canvas)
    fill = (255, 40, 50, 255) if style == "red" else (235, 235, 235, 150)
    d.text((size // 2, size // 8), shown, font=font, fill=fill)
    canvas = canvas.resize((int(canvas.width * CONDENSE), canvas.height))  # condensed look
    if style == "red":
        glow = canvas.filter(ImageFilter.GaussianBlur(size / 10))
        g = Image.new("RGBA", canvas.size, (255, 0, 30, 0))
        g.putalpha(glow.getchannel("A"))
        canvas = Image.alpha_composite(Image.alpha_composite(g, g), canvas)
    full = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    full.paste(canvas, ((W - canvas.width) // 2, (H - canvas.height) // 2), canvas)
    return np.array(full)


def overlay(img, rgba):
    a = rgba[..., 3:4].astype(np.float32) / 255
    rgb = rgba[..., [2, 1, 0]].astype(np.float32)
    return (img * (1 - a) + rgb * a).astype(np.uint8)


_WM = {}


def watermark(img, handle):
    H, W = img.shape[:2]
    if (W, H, handle) not in _WM:
        size = int(min(W, H) * 0.035)
        font = ImageFont.truetype(FONT, size)
        tw = int(font.getlength(handle))
        layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ImageDraw.Draw(layer).text((W - tw - int(W * 0.03), int(H * 0.04)), handle, font=font,
                                   fill=(255, 255, 255, 200), stroke_width=2, stroke_fill=(0, 0, 0, 120))
        _WM[(W, H, handle)] = np.array(layer)
    return overlay(img, _WM[(W, H, handle)])


def outro(W, H, t, handle):
    img = np.zeros((H, W, 3), np.uint8)
    a = min(1, t / 0.4)
    size = int(min(W, H) * 0.11)
    font = ImageFont.truetype(FONT, size)
    hue = (t * 60) % 180
    col = cv2.cvtColor(np.uint8([[[hue, 200, 255]]]), cv2.COLOR_HSV2RGB)[0, 0]
    pil = Image.fromarray(img)
    d = ImageDraw.Draw(pil)
    tw = font.getlength(handle)
    d.text(((W - tw) / 2, H / 2 - size / 2), handle, font=font,
           fill=tuple(int(c * a) for c in col))
    return cv2.cvtColor(np.array(pil), cv2.COLOR_RGB2BGR)


# ---------------------------------------------------------------- timeline
def build_timeline(spec):
    kills = sorted(spec["kills"], key=lambda k: -k.get("score", 1))
    if len(kills) < 3:
        sys.exit("need at least 3 kills")
    drop_kill, final_kill, rest = kills[0], kills[1], kills[2:]
    # chronological feel for the rest, keep source order
    # rest keeps the given order (pick_kills.py writes it in play order)
    cuts = list(MONTAGE_CUTS)
    slots = list(zip(cuts[:-1], cuts[1:]))
    # merge shortest neighbouring slots until slots == kills (two-beat holds)
    # merge shortest neighbours into holds of at most ~2 beats until slots == kills
    while len(slots) > len(rest):
        pairs = [j for j in range(len(slots) - 1) if slots[j + 1][1] - slots[j][0] <= 1.05]
        if not pairs:
            break
        i = min(pairs, key=lambda j: slots[j + 1][1] - slots[j][0])
        slots[i:i + 2] = [(slots[i][0], slots[i + 1][1])]
    if len(rest) < len(slots):
        print(f"note: {len(rest)} kills for {len(slots)} beat slots, reusing kills (pick ~{len(slots)} for no repeats)")
        rest = [rest[i % len(rest)] for i in range(len(slots))]
    rest = rest[:len(slots)]
    show = spec.get("showcase") or [{"clip": kills[-1]["clip"], "start": max(0, kills[-1]["t"] - 4)}]
    tl = []
    s0 = show[0]
    tl.append(dict(kind="showcase", a=INTRO[0], b=INTRO[1], clip=s0["clip"], src=s0["start"], speed=0.8))
    tl.append(dict(kind="drop", a=DROP1[0], b=DROP1[1], clip=drop_kill["clip"],
                   src=drop_kill["t"] - KILL_LEAD / FPS, speed=1.0, kill=DROP1[0] + KILL_LEAD / FPS))
    s1 = show[1] if len(show) > 1 else s0
    tl.append(dict(kind="showcase", a=BREATHER[0], b=BREATHER[1], clip=s1["clip"],
                   src=s1["start"] + (0 if len(show) > 1 else 0.4), speed=0.5))
    for (a, b), k in zip(slots, rest):
        tl.append(dict(kind="kill", a=a, b=b, clip=k["clip"], src=k["t"] - KILL_LEAD / FPS, speed=1.0,
                       kill=a + KILL_LEAD / FPS))
    # final: freeze on the moment before the final kill, then play it out
    fk = final_kill["t"]
    tl.append(dict(kind="freeze", a=FREEZE[0], b=FREEZE[1], clip=final_kill["clip"], src=fk - 0.35, speed=0.0))
    tl.append(dict(kind="final", a=FREEZE[1], b=FINAL_END, clip=final_kill["clip"], src=fk - 0.35, speed=1.0,
                   kill=FREEZE[1] + 0.35))
    return tl


def lyric_events(path):
    if path and os.path.exists(path):
        return json.load(open(path))
    return [
        {"word": "YOU", "a": 0.55, "b": 1.15, "style": "red"},
        {"word": "SHOULD", "a": 1.15, "b": 1.95, "style": "red"},
        {"word": "NOW", "a": 1.95, "b": 2.50, "style": "red"},
        {"word": "I", "a": 2.50, "b": 3.97, "style": "red"},
        {"word": "TAKE", "a": 14.00, "b": 14.25, "style": "ghost"},
        {"word": "CON", "a": 14.25, "b": 14.60, "style": "ghost"},
        {"word": "TROL", "a": 14.60, "b": 14.93, "style": "ghost"},
    ]


# ---------------------------------------------------------------- render
def render(spec, song, out, W, H, handle, lyrics_path, preview_every=0):
    tl = build_timeline(spec)
    lyrics = lyric_events(lyrics_path)
    cut_frames = [F(s["a"]) for s in tl[1:]]
    lines = SpeedLines(W, H)
    tmp = out + ".video.mp4"
    ff = os.environ.get("FFMPEG") or shutil.which("ffmpeg")
    if not ff:
        import imageio_ffmpeg
        ff = imageio_ffmpeg.get_ffmpeg_exe()
    proc = subprocess.Popen([ff, "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24",
                             "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "medium",
                             "-crf", "17", "-pix_fmt", "yuv420p", tmp], stdin=subprocess.PIPE)
    rng = random.Random(7)
    angles = {c: rng.choice([0, 180, 10, 190, -8]) for c in cut_frames}
    total = F(OUTRO[1])
    for fi in range(total):
        t = fi / FPS
        if t >= OUTRO[0]:
            img = outro(W, H, t - OUTRO[0], handle)
            proc.stdin.write(img.tobytes())
            continue
        seg = next((s for s in tl if s["a"] <= t < s["b"]), tl[-1])
        clip = Clip.get(seg["clip"])
        src_t = seg["src"] + (t - seg["a"]) * seg["speed"]
        img = grade(cover(clip.at(src_t), W, H))

        if seg["kind"] == "freeze":
            img = zoom(img, 1 + 0.06 * (t - seg["a"]) / (seg["b"] - seg["a"]))
        if "kill" in seg:
            dk = t - seg["kill"]
            if dk >= 0:
                img = zoom(img, 1 + 0.07 * math.exp(-dk / 0.12))
                if dk < 4 / FPS:
                    img = rgb_split(img, W * 0.006 * (1 - dk * FPS / 4))
        if seg["kind"] == "drop" and t >= DROP1[0] + 3 / FPS:
            img = red_frame(img, t - DROP1[0])
        if seg["kind"] == "drop" and t < DROP1[0] + 4 / FPS:
            img = radial_blur(img, 0.25 * (1 - (t - DROP1[0]) * FPS / 4))
        if any(a <= t < b for a, b in SPEED_LINES):
            img = lines.draw(img)
        # whip blur around each cut: 2 frames out, 2 frames in
        for c in cut_frames:
            d = fi - c
            if -2 <= d <= 1 and c != F(FREEZE[1]):
                k = {-2: 0.5, -1: 1.0, 0: 1.0, 1: 0.5}[d]
                shift = (0.06 if d < 0 else -0.06) * k
                img = whip(img, k, angles[c], shift)
        for ft, n in FLASHES:
            d = fi - F(ft)
            if 0 <= d < n + 2:
                img = flash(img, 1.0 if d < n else 0.5 / (d - n + 1))
        for ev in lyrics:
            if ev["a"] <= t < ev["b"]:
                img = overlay(img, text_layer(W, H, ev["word"], ev["style"], t - ev["a"]))
        if CRUSH[0] <= t:
            img = levels_crush(img, min(1, (t - CRUSH[0]) / (CRUSH[1] - CRUSH[0])))
        elif t < 0.3:
            img = levels_crush(img, 1 - t / 0.3)
        img = watermark(img, handle)
        proc.stdin.write(img.tobytes())
        if preview_every and fi % preview_every == 0:
            cv2.imwrite(f"{out}.f{fi:04d}.jpg", img)
        if fi % 60 == 0:
            print(f"  {t:5.1f}s / {total / FPS:.1f}s", flush=True)
    proc.stdin.close()
    proc.wait()
    subprocess.run([ff, "-loglevel", "error", "-y", "-i", tmp, "-i", song, "-map", "0:v", "-map", "1:a",
                    "-c:v", "copy", "-af", "apad", "-c:a", "aac", "-b:a", "256k", "-t", f"{total / FPS:.3f}", out], check=True)
    os.remove(tmp)
    print("wrote", out)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--kills", required=True)
    ap.add_argument("--song", required=True, help="reference video or audio file (audio track is used)")
    ap.add_argument("--out", default="edit.mp4")
    ap.add_argument("--aspect", default="9:16", choices=["16:9", "9:16"])
    ap.add_argument("--handle", default="YOUSEF")
    ap.add_argument("--lyrics", default=os.path.join(HERE, "lyrics.json"))
    ap.add_argument("--preview-every", type=int, default=0)
    a = ap.parse_args()
    W, H = (1920, 1080) if a.aspect == "16:9" else (1080, 1920)
    render(json.load(open(a.kills)), a.song, a.out, W, H, a.handle, a.lyrics, a.preview_every)
