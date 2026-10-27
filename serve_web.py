import http.server
import socketserver
import sys

PORT = 8080
DIRECTORY = "build/web"

class FlutterWebHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable Cross-Origin Isolation for high performance Wasm threading if needed
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'credentialless')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

FlutterWebHandler.extensions_map.update({
    '.wasm': 'application/wasm',
    '.js': 'application/javascript',
    '.mjs': 'application/javascript',
    '.json': 'application/json',
    '.css': 'text/css',
    '.html': 'text/html',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml',
})

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("0.0.0.0", PORT), FlutterWebHandler) as httpd:
    print(f"Flutter web server running at http://localhost:{PORT}")
    sys.stdout.flush()
    httpd.serve_forever()
