#!/usr/bin/env bash
# Compila el APK de release con el preset "Android" (firma con clave de debug).
# Requisitos: Godot 4.7.x + export templates, JDK 17, Android SDK (ver README).
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT="${GODOT:-godot}"
OUT="${1:-build/llave-del-laberinto-v0.2-alpha.apk}"
export JAVA_HOME="${JAVA_HOME:-$HOME/.local/opt/jdk17}"

mkdir -p build
"$GODOT" --headless --path . --export-release "Android" "$OUT"
echo "APK: $OUT ($(du -h "$OUT" | cut -f1))"
