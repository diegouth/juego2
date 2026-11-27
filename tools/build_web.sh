#!/usr/bin/env bash
# Exporta la version web (HTML5) a build/web/.
# Para probarla hace falta un servidor con cabeceras COOP/COEP porque el
# runtime usa hilos (SharedArrayBuffer):
#   ./tools/serve_web.sh   y abrir http://localhost:8060/
set -euo pipefail
cd "$(dirname "$0")/.."

GODOT="${GODOT:-godot}"
OUT="${1:-build/web/index.html}"

mkdir -p build/web
"$GODOT" --headless --path . --export-release "Web" "$OUT"
echo "Web: build/web/ ($(du -sh build/web | cut -f1))"
