#!/usr/bin/env bash
# Sirve build/web/ con las cabeceras que exige Godot 4 en el navegador.
set -euo pipefail
cd "$(dirname "$0")/.."
PORT="${PORT:-8060}"
echo "http://localhost:$PORT/"
exec python3 - "$PORT" <<'PY'
import functools, http.server, socketserver, sys
port = int(sys.argv[1])
class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()
handler = functools.partial(Handler, directory="build/web")
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", port), handler) as httpd:
    httpd.serve_forever()
PY
