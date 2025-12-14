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
        try await request(path: "/categories", as: [Category].self)
    }

    func fetchProducts() async throws -> [Product] {
        try await request(path: "/products", as: [Product].self)
    }

    func fetchOrders() async throws -> [Order] {
        try await request(path: "/orders", as: [Order].self)
    }

    private func request<T: Decodable>(path: String, as type: T.Type) async throws -> T {
        guard let baseURL else { throw APIError.badURL }
        let url = baseURL.appendingPathComponent(path)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
