import Foundation
import CoreData
import Combine

final class CartStore: ObservableObject {
    @Published private(set) var itemIDs: Set<NSManagedObjectID> = []

    var count: Int { itemIDs.count }

    func contains(_ product: Product) -> Bool {
        itemIDs.contains(product.objectID)
    }

    func add(_ product: Product) {
        itemIDs.insert(product.objectID)
    }

    func remove(_ product: Product) {
        itemIDs.remove(product.objectID)
    }

    func clear() {
        itemIDs.removeAll()
    }

    func products(in context: NSManagedObjectContext) -> [Product] {
        itemIDs
            .compactMap { id in
                (try? context.existingObject(with: id)) as? Product
            }
            .sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
