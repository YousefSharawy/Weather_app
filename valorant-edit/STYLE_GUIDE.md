# Valorant Edit Style Guide (learned from reference `valorant.MP4`)

Reference: 28.6 s, 720x406, 30 fps, 858 frames, song ≈ **123 BPM** (1 beat ≈ 0.49 s ≈ 15 frames).
Every frame was analysed: frame difference, colour-histogram change, sharpness (motion-blur),
optical flow (pan / zoom / rotation), brightness, saturation, plus beat / onset / energy detection on the audio.

## 1. Structure (timeline of the reference)

| Time (s) | Section | What happens | Music |
|---|---|---|---|
| 0.00–0.30 | Fade-in | Crushed-black "levels" fade in (not a plain opacity fade) | quiet |
| 0.30–3.90 | **Intro / lyric hook** | One knife clip (red kunai inspect/throws). Lyric text **"YOU SHOULD KNOW I"** types in letter by letter, big, centered, red with glow | vocals, no strong beat |
| 3.90–4.00 | **Pre-drop glitch** | Text letter flickers/rotates ("I" → "?" → "I"), ghost doubles | riser |
| 4.00 | **DROP 1** | 1-frame white flash + radial zoom blur | first beat hit |
| 4.10–4.70 | **Reaction frame** | Gameplay shrinks into a frame with a glowing red border, red vignette background, cut-out reaction face on the right | hit |
| 4.70–7.00 | **Breather** | Calm, slow-motion skin/knife showcase (lowest optical flow in the video: 1.6) | energy dips (build) |
| 7.00 | **DROP 2** | Full white flash (sharpness → 4) | main drop |
| 7.00–15.00 | **Fast montage** | Kills every ½–1 beat, whip blur between clips, white anime speed lines, RGB split. Lyric **"TAKE CONTROL"** as huge semi-transparent letters behind the action (14.0–14.9) | high energy |
| 15.00–22.60 | **Beat-locked chain** | **Exactly one kill per beat** (cut gaps 0.43–0.53 s). Every clip = one kill with a whip transition. Lyric **"IGNITION / SESSION"** style text 21.0–22.6 | peak energy |
| 22.70–23.60 | **Freeze / tension** | Near-static frame (optical flow 0.1) for about 2 beats | break |
| 23.70–24.00 | **Final kill** | Last and flashiest kill (pink ability), impact on the returning beat | final hit |
| 24.00–24.50 | **Crush to black** | Levels/threshold crush: shadows go black first, highlights last | tail |
| 24.60–28.60 | **Outro card** | Instagram logo + @handle, gradient colour-cycles on the logo | outro |

## 2. Cut timing rules (measured)

- **28 transitions** were detected. From 4 s onward, **every one lands on a beat**.
  The sharpest blur frame sits **+2 to +4 frames after the detected beat**, so the new clip is on screen on the hit.
- Cut spacing: 1 beat (0.49 s) in the chain section; ½ beat (0.23–0.27 s) for doubles; 2 beats for hero moments.
- **The kill lands on the beat.** The clip starts 0–3 frames before the kill (blood splash or skull icon), then holds about 10–12 frames after it. There's no walk-up: every clip starts at the action.
- No cuts before the first beat (intro). Energy follows the song: long shots when quiet, one cut per beat at peak.

## 3. Transitions and effects vocabulary

1. **Whip-blur cut** (default, about 25x): 2–4 frames of directional motion blur (sharpness drops to 10–30% of normal) that match the flick direction, over the cut.
2. **White flash**: 1–2 frames, only on the two big drops (4.0 s and 7.0 s).
3. **Radial zoom blur** plus the flash on drop 1.
4. **Reaction frame**: shrink to about 80% with a glowing red border and a cut-out face overlay. Used once.
5. **Speed lines**: thin white horizontal streaks over fast sections (7–15 s, 18.8–20.7 s).
6. **RGB split / chromatic aberration** on impact frames (cyan/red edge fringing).
7. **Freeze-hold** before the final kill.
8. **Levels crush to black** as the ending.

## 4. Text (lyrics)

- Words are revealed **letter by letter**, one letter every 2–3 frames, and each word ends on a beat.
- Intro: bold condensed font, **red fill with red outer glow**, centered, about 40% of frame height.
- Mid-video: **huge semi-transparent grey/white letters** in the background layer, partly behind the hands/weapon.
- Only 3 lyric moments in 25 s. Text is an accent, not subtitles.

## 5. Look / grade

- Saturation and contrast pushed (mean saturation ~90–130 against ~60–70 for raw gameplay), crisp sharpening.
- The HUD is kept (kill feed and skull icon are the visual "proof" of the kill).
- Creator watermark (IG icon + @handle, top-right) plus a name bottom-left the whole time.
- Knife/melee kills plus ability kills. Big, flashy skins are the stars.

## 6. How this becomes your edit

1. Detect kills in your clips: skull icon or kill-banner appearance, plus the audio spike of the kill sound.
2. Detect beats and energy sections in your song.
3. Put your 1–2 flashiest kills on the drops, the rest one per beat in the peak section, and a slow showcase clip in the quiet part.
4. Apply the effect vocabulary above at the same positions relative to the music, then render.

## 7. Rendering (`edit.py`)

The song is taken from the reference video, so the reference's measured cut grid is reused 1:1.

```
python edit.py --kills kills.json --song valorant.MP4 --out my_edit.mp4 --aspect 16:9 --handle @me
```

- `kills.json` lists `showcase` shots (slow knife/skin moments for the intro and breather) and `kills`
  (`clip`, `t` = second the kill registers, `score` = hype). The top score goes on drop 1, the second on the
  final kill after the freeze, and the rest go on the beat grid one per beat. If there are fewer kills than
  slots, neighbouring slots merge into 2-beat holds.
- Lyric text defaults to the reference's ("YOU SHOULD NOW I", "TAKE CONTROL"). Override it with `lyrics.json`.
- The reference audio ends at 26.77 s. Silence is padded so the outro card keeps its full length.
- Needs: `pip install opencv-python-headless numpy pillow librosa imageio-ffmpeg`, with ffmpeg on PATH or `FFMPEG=`.
