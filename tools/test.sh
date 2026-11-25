#!/usr/bin/env bash
# Prueba end-to-end de las mecánicas, sin ventana.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
"$GODOT" --headless --path . --audio-driver Dummy res://tests/e2e.tscn
