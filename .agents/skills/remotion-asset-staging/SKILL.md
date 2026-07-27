---
name: remotion-asset-staging
description: Actionable procedure for staging local image assets and executing explicit FFmpeg audio stream muxing for local Remotion rendering.
---

# Remotion Asset Staging & Audio Muxing

Use this skill when composing/rendering videos with Remotion in local offline mode.

## 1. Asset Staging (Prevents 404 image load errors)

Remotion's local headless browser web server loads assets relative to `remotion-composer/public/assets/`.

Before triggering `video_compose` with `operation: "remotion_render"`:
```python
import shutil, pathlib

public_img_dir = pathlib.Path("remotion-composer/public/assets/images")
public_img_dir.mkdir(parents=True, exist_ok=True)

# Copy project image assets
for img in pathlib.Path("projects/<slug>/assets/images").glob("*"):
    shutil.copy(img, public_img_dir / img.name)
```

## 2. Post-Render Audio Muxing (Prevents silent output)

If the rendered video file has a silent audio stream (-91 dB), execute an explicit FFmpeg muxing pass with the pre-mixed audio track:

```bash
ffmpeg -y -i "projects/<slug>/renders/remotion_raw.mp4" \
          -i "projects/<slug>/assets/audio/mixed_audio.mp3" \
          -map 0:v:0 -map 1:a:0 \
          -c:v copy -c:a aac -b:a 192k -shortest \
          "projects/<slug>/renders/final_output.mp4"
```

## 3. Burn Subtitles Pass

To burn word-level subtitles into the final video:
```bash
ffmpeg -y -i "projects/<slug>/renders/final_output.mp4" \
          -vf "subtitles=projects/<slug>/assets/subtitles.srt" \
          -c:a copy \
          "projects/<slug>/renders/final_subtitled.mp4"
```
