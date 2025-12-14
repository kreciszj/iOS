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

struct Order: Identifiable, Codable, Equatable {
    let id: Int
    let customerName: String
    let createdAt: String
    let status: String
    let note: String
    let items: [OrderItem]

    var total: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.unitPrice) }
    }
}

struct OrderItem: Identifiable, Codable, Equatable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}
