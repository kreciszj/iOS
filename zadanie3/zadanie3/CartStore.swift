import Foundation
import CoreData
import Combine

final class CartStore: ObservableObject {
    @Published private(set) var quantities: [NSManagedObjectID: Int] = [:]

    var totalItemsCount: Int {
        quantities.values.reduce(0, +)
    }

    var uniqueItemsCount: Int {
        quantities.count
    }

    func quantity(for product: Product) -> Int {
        quantities[product.objectID] ?? 0
    }

    func add(_ product: Product) {
        let id = product.objectID
        quantities[id, default: 0] += 1
    }

    func removeOne(_ product: Product) {
        let id = product.objectID
        guard let current = quantities[id] else { return }
        if current <= 1 {
            quantities.removeValue(forKey: id)
        } else {
            quantities[id] = current - 1
        }
    }

    func removeAll(of product: Product) {
        quantities.removeValue(forKey: product.objectID)
    }

    func clear() {
        quantities.removeAll()
    }

    func products(in context: NSManagedObjectContext) -> [Product] {
        quantities.keys
            .compactMap { id in
                (try? context.existingObject(with: id)) as? Product
            }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
