from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json

CATEGORIES = [
    {"id": 1, "name": "Elektronika"},
    {"id": 2, "name": "Dom"},
    {"id": 3, "name": "Sport"},
    {"id": 4, "name": "Ksiazki"}
]

PRODUCTS = [
    {"id": 101, "name": "Sluchawki", "price": 222.00, "categoryId": 1},
    {"id": 102, "name": "Klawiatura", "price": 333.00, "categoryId": 1},
    {"id": 103, "name": "Czajnik", "price": 321.12, "categoryId": 2},
    {"id": 104, "name": "Patelnia", "price": 123.90, "categoryId": 2},
    {"id": 105, "name": "Piłka", "price": 112.10, "categoryId": 3},
    {"id": 106, "name": "Białe noce", "price": 24.07, "categoryId": 4},
]

ORDERS = [
    {
        "id": 5001,
        "customerName": "Jan",
        "createdAt": "2025-12-14 18:30",
        "status": "NEW",
        "note": "prosze dostarczyc pod drzwi",
        "items": [
            {"id": 9001, "productId": 101, "quantity": 1, "unitPrice": 222.00},
            {"id": 9002, "productId": 106, "quantity": 2, "unitPrice": 24.07}
        ]
    },
    {
        "id": 5002,
        "customerName": "Ala",
        "createdAt": "2025-12-14 19:05",
        "status": "PAID",
        "note": "prosze zapakowac",
        "items": [
            {"id": 9003, "productId": 104, "quantity": 1, "unitPrice": 123.90},
            {"id": 9004, "productId": 103, "quantity": 1, "unitPrice": 321.12}
        ]
    }
]

class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload, status=200):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/" or self.path == "/health":
            return self._send_json({"status": "ok", "endpoints": ["/categories", "/products", "/orders"]})

        if self.path == "/categories":
            return self._send_json(CATEGORIES)

        if self.path == "/products":
            return self._send_json(PRODUCTS)

        if self.path == "/orders":
            return self._send_json(ORDERS)

        return self._send_json({"error": "Not found"}, status=404)

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    host = "127.0.0.1"
    port = 3000
    server = ThreadingHTTPServer((host, port), Handler)
    print(f"Backend działa: http://localhost:{port}")
    server.serve_forever()
