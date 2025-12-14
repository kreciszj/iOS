import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
}

struct Product: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let price: Double
    let categoryId: Int
}
