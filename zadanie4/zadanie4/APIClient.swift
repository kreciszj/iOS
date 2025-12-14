import Foundation

enum APIError: LocalizedError {
    case badURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .badURL: return "Niepoprawny URL"
        case .invalidResponse: return "Niepoprawna odp serwera."
        case .httpStatus(let code): return "Serwer zwrocil blad HTTP: \(code)."
        case .decoding(let err): return "Blad JSON: \(err.localizedDescription)"
        }
    }
}

final class APIClient {
    private let baseURLString = "http://localhost:3000"
    private var baseURL: URL? { URL(string: baseURLString) }

    func fetchCategories() async throws -> [Category] {
        try await request(path: "/categories", method: "GET", body: nil, as: [Category].self)
    }

    func fetchProducts() async throws -> [Product] {
        try await request(path: "/products", method: "GET", body: nil, as: [Product].self)
    }

    func fetchOrders() async throws -> [Order] {
        try await request(path: "/orders", method: "GET", body: nil, as: [Order].self)
    }

    func createProduct(_ newProduct: NewProduct) async throws -> Product {
        let body = try JSONEncoder().encode(newProduct)
        return try await request(path: "/products", method: "POST", body: body, as: Product.self, expected: [200, 201])
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        as type: T.Type,
        expected: [Int] = Array(200...299)
    ) async throws -> T {
        guard let baseURL else { throw APIError.badURL }
        let url = baseURL.appendingPathComponent(path)

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        if body != nil {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard expected.contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
