"""Scan a folder of Valorant clips, find every kill, and cut each one into its own short clip.

Detection combines three signals per clip:
  * audio   - sharp transient of the kill sound (onset strength, high-frequency weighted)
  * banner  - sudden change in the bottom-centre HUD region where the kill skull/banner pops
  * feed    - sudden change in the top-right kill feed
A candidate needs a strong audio hit, or a medium audio hit backed by one of the visual signals.

Output (in --out, default <clips>/kills):
  kill_001.mp4 ...     standalone cuts, PRE seconds before the kill to POST seconds after
  kill_001.jpg ...     thumbnail at the kill moment
  candidates.json      [{id, file, source, t, score, signals}]
  index.html           gallery to watch every kill and pick favourites

Usage:
  python find_kills.py /Volumes/lexa4/valorant
  python find_kills.py /Volumes/lexa4/valorant --sensitivity 0.8   # lower = more candidates
"""
import argparse, glob, html, json, os, shutil, subprocess, sys
import numpy as np

PRE, POST = 2.0, 2.5
SR = 22050
VFPS = 10  # visual sampling rate
EXTS = (".mp4", ".mov", ".mkv", ".m4v", ".avi", ".webm")


def ffmpeg_bin():
    ff = os.environ.get("FFMPEG") or shutil.which("ffmpeg")
    if not ff:
        import imageio_ffmpeg
        ff = imageio_ffmpeg.get_ffmpeg_exe()
    return ff


FF = ffmpeg_bin()


def robust_z(x):
    med = np.median(x)
    mad = np.median(np.abs(x - med))
    scale = max(1.4826 * mad, 0.5 * np.std(x), 1e-6)  # sparse signals have MAD == 0
    return (x - med) / scale


def audio_curve(path):
    """Kill-sound likelihood sampled at VFPS."""
    import librosa
    raw = subprocess.run([FF, "-loglevel", "error", "-i", path, "-vn", "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"],
                         capture_output=True).stdout
    y = np.frombuffer(raw, np.float32)
    if len(y) < SR:
        return None
    S = np.abs(librosa.stft(y, n_fft=1024, hop_length=512))
    freqs = librosa.fft_frequencies(sr=SR, n_fft=1024)
    w = np.clip(freqs / 3000, 0.2, 1.5)[:, None]  # the kill "ding" lives high up
    flux = np.maximum(0, np.diff(np.log1p(S * w), axis=1)).sum(0)
    t = np.arange(len(flux)) * 512 / SR
    grid = np.arange(0, t[-1], 1 / VFPS)
    return robust_z(np.interp(grid, t, flux))


def visual_curves(path, n):
    """Change in the banner (bottom-centre) and kill-feed (top-right) regions, sampled at VFPS."""
    W, H = 320, 180
    raw = subprocess.run([FF, "-loglevel", "error", "-i", path, "-an", "-vf", f"fps={VFPS},scale={W}:{H}",
                          "-pix_fmt", "gray", "-f", "rawvideo", "-"], capture_output=True).stdout
    fr = np.frombuffer(raw, np.uint8)
    k = len(fr) // (W * H)
    fr = fr[:k * W * H].reshape(k, H, W).astype(np.float32)
    banner = fr[:, int(H * 0.68):int(H * 0.88), int(W * 0.40):int(W * 0.60)]
    feed = fr[:, int(H * 0.06):int(H * 0.32), int(W * 0.70):int(W * 0.99)]
    whole = fr

    def change(r):
        d = np.abs(np.diff(r, axis=0)).mean(axis=(1, 2))
        return np.concatenate([[0], d])

    # subtract whole-frame motion so camera flicks don't look like HUD events
    wm = change(whole)
    b = robust_z(np.maximum(0, change(banner) - wm))
    f = robust_z(np.maximum(0, change(feed) - wm))
    b = np.pad(b, (0, max(0, n - len(b))))[:n]
    f = np.pad(f, (0, max(0, n - len(f))))[:n]
    return b, f


def detect(path, sens):
    a = audio_curve(path)
    if a is None:
        return []
    b, f = visual_curves(path, len(a))
    # visual events can trail the sound by a few frames: take local max within +0.3s
    win = int(0.3 * VFPS)
    bmax = np.array([b[i:i + win + 1].max() for i in range(len(b))])
    fmax = np.array([f[i:i + win + 1].max() for i in range(len(f))])
    score = a + 0.6 * np.maximum(bmax, fmax)
    ok = ((a > 6 * sens) | ((a > 3.5 * sens) & (np.maximum(bmax, fmax) > 3 * sens)))
    idx = [i for i in range(1, len(a) - 1) if ok[i] and a[i] >= a[i - 1] and a[i] >= a[i + 1]]
    # non-max suppression: one kill per 0.6s
    idx.sort(key=lambda i: -score[i])
    keep = []
    for i in idx:
        if all(abs(i - j) > 0.6 * VFPS for j in keep):
            keep.append(i)
    keep.sort()
    return [dict(t=round(i / VFPS, 2), score=round(float(score[i]), 1),
                 signals=dict(audio=round(float(a[i]), 1), banner=round(float(bmax[i]), 1),
                              feed=round(float(fmax[i]), 1))) for i in keep]


def cut(src, t, dst):
    s = max(0, t - PRE)
    subprocess.run([FF, "-loglevel", "error", "-y", "-ss", f"{s:.3f}", "-i", src, "-t", f"{PRE + POST:.3f}",
                    "-c:v", "libx264", "-preset", "veryfast", "-crf", "16", "-c:a", "aac", "-b:a", "192k",
                    "-movflags", "+faststart", dst], check=True)
    subprocess.run([FF, "-loglevel", "error", "-y", "-ss", f"{t:.3f}", "-i", src, "-frames:v", "1",
                    "-vf", "scale=480:-2", dst[:-4] + ".jpg"], check=True)
    return t - s  # kill time inside the cut


def gallery(out, cands):
    cards = []
    for c in cands:
        name = os.path.basename(c["file"])
        cards.append(f"""
<figure data-id="{c['id']}">
  <video src="{html.escape(name)}" poster="{html.escape(name[:-4])}.jpg" preload="none" controls loop muted></video>
  <figcaption><b>#{c['id']}</b> <span>{html.escape(os.path.basename(c['source']))} @ {c['t']:.1f}s</span>
  <span class="s">score {c['score']}</span>
  <label><input type="checkbox" class="pick"> pick</label></figcaption>
</figure>""")
    page = f"""<!doctype html><html><head><meta charset="utf-8"><title>Kill Picker</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
body{{margin:0;background:#0f1115;color:#e8e8ea;font:14px/1.4 system-ui,sans-serif}}
header{{position:sticky;top:0;background:#16181ddd;backdrop-filter:blur(6px);padding:12px 16px;display:flex;gap:12px;align-items:center;flex-wrap:wrap;z-index:1}}
h1{{font-size:16px;margin:0}} code{{background:#23262d;padding:4px 8px;border-radius:6px;user-select:all}}
main{{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px;padding:16px}}
figure{{margin:0;background:#16181d;border-radius:10px;overflow:hidden;border:2px solid transparent}}
figure.on{{border-color:#ff4655}} video{{width:100%;display:block;background:#000;aspect-ratio:16/9}}
figcaption{{padding:8px 10px;display:flex;gap:8px;flex-wrap:wrap;align-items:center}}
.s{{color:#9aa0aa}} label{{margin-left:auto;cursor:pointer}}
</style></head><body>
<header><h1>{len(cands)} kills found</h1><span>Picked:</span><code id="out">none</code>
<span class="s">Hover a card to play. Tell Claude the picked numbers, and your 2 favourites for the drop and the final kill.</span></header>
<main>{''.join(cards)}</main>
<script>
const out=document.getElementById('out');
function upd(){{const ids=[...document.querySelectorAll('figure')].filter(f=>f.querySelector('.pick').checked).map(f=>f.dataset.id);
document.querySelectorAll('figure').forEach(f=>f.classList.toggle('on',f.querySelector('.pick').checked));
out.textContent=ids.length?ids.join(','):'none';}}
document.querySelectorAll('.pick').forEach(c=>c.addEventListener('change',upd));
document.querySelectorAll('video').forEach(v=>{{v.addEventListener('mouseenter',()=>v.play());v.addEventListener('mouseleave',()=>v.pause());}});
</script></body></html>"""
    open(os.path.join(out, "index.html"), "w").write(page)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("clips")
    ap.add_argument("--out")
    ap.add_argument("--sensitivity", type=float, default=1.0)
    a = ap.parse_args()
    out = a.out or os.path.join(a.clips, "kills")
    os.makedirs(out, exist_ok=True)
    files = sorted(p for p in glob.glob(os.path.join(a.clips, "*")) if p.lower().endswith(EXTS)
                   and not os.path.basename(p).startswith(("._", "yousef_edit")))
    if not files:
        sys.exit(f"no videos in {a.clips}")
    cands = []
    for n, p in enumerate(files, 1):
        found = detect(p, a.sensitivity)
        print(f"[{n}/{len(files)}] {os.path.basename(p)}: {len(found)} kill(s)", flush=True)
        for k in found:
            cid = len(cands) + 1
            dst = os.path.join(out, f"kill_{cid:03d}.mp4")
            k_in = cut(p, k["t"], dst)
            cands.append(dict(id=cid, file=dst, source=p, t=k["t"], t_in_cut=round(k_in, 3),
                              score=k["score"], signals=k["signals"]))
        json.dump(cands, open(os.path.join(out, "candidates.json"), "w"), indent=1)
    gallery(out, cands)
    print(f"\n{len(cands)} kills -> {out}\nopen {os.path.join(out, 'index.html')}")


if __name__ == "__main__":
    main()
