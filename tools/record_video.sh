#!/usr/bin/env bash
# Graba el video de evidencia con el bot de demostración y lo convierte a MP4.
# Uso: ./tools/record_video.sh   (requiere sesión gráfica: usa la GPU real)
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
cp project.godot project.godot.bak
trap 'mv project.godot.bak project.godot' EXIT
python3 - <<'PY'
s = open("project.godot").read()
s = s.replace('GameState="*res://scripts/game_state.gd"',
              'GameState="*res://scripts/game_state.gd"\nDemoBot="*res://tests/demo.gd"')
open("project.godot", "w").write(s)
PY
mkdir -p build docs/video
"$GODOT" --path . --audio-driver Dummy --resolution 960x540 \
         --fixed-fps 30 --write-movie build/demo.avi res://scenes/main_menu.tscn
ffmpeg -y -loglevel error -i build/demo.avi -stream_loop -1 -i assets/audio/music.ogg \
       -c:v libx264 -preset slow -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k \
       -shortest -movflags +faststart docs/video/demo.mp4
rm -f build/demo.avi
echo "video: docs/video/demo.mp4 ($(du -h docs/video/demo.mp4 | cut -f1))"
