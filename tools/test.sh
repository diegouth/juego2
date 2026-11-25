#!/usr/bin/env bash
# Prueba end-to-end de las mecánicas, sin ventana.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
# Primero se refresca el cache de clases globales (class_name) para que los
# scripts nuevos se resuelvan igual que en el editor.
"$GODOT" --headless --path . --import >/dev/null 2>&1 || true
"$GODOT" --headless --path . --audio-driver Dummy res://tests/e2e.tscn
