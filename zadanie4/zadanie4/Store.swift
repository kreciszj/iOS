import Foundation
import Combine
import CoreData

@MainActor
final class Store: ObservableObject {
    @Published var categories: [Category] = []
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let api = APIClient()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadFromCoreData()
    }

    func load() async {
        if categories.isEmpty && products.isEmpty {
            loadFromCoreData()
        }

        isLoading = true
        errorMessage = nil

        do {
            async let cats = api.fetchCategories()
            async let prods = api.fetchProducts()
            let (c, p) = try await (cats, prods)

            let sortedC = c.sorted { $0.name.lowercased() < $1.name.lowercased() }
            let sortedP = p.sorted { $0.name.lowercased() < $1.name.lowercased() }

            categories = sortedC
            products = sortedP

            saveToCoreData(categories: sortedC, products: sortedP)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    func categoryName(for product: Product) -> String {
        categories.first(where: { $0.id == product.categoryId })?.name ?? "Brak"
    }

    private func loadFromCoreData() {
        do {
            let catReq = NSFetchRequest<NSManagedObject>(entityName: "CategoryEntity")
            let prodReq = NSFetchRequest<NSManagedObject>(entityName: "ProductEntity")

            let catObjects = try context.fetch(catReq)
            let prodObjects = try context.fetch(prodReq)

            let loadedCategories: [Category] = catObjects.compactMap { obj in
                guard
                    let name = obj.value(forKey: "name") as? String
                else { return nil }

                let id = obj.value(forKey: "id") as? Int64 ?? 0
                return Category(id: Int(id), name: name)
            }

            let loadedProducts: [Product] = prodObjects.compactMap { obj in
                guard
                    let name = obj.value(forKey: "name") as? String
                else { return nil }

                let id = obj.value(forKey: "id") as? Int64 ?? 0
                let price = obj.value(forKey: "price") as? Double ?? 0
                let categoryId = obj.value(forKey: "categoryId") as? Int64 ?? 0

                return Product(id: Int(id), name: name, price: price, categoryId: Int(categoryId))
            }

            categories = loadedCategories.sorted { $0.name.lowercased() < $1.name.lowercased() }
            products = loadedProducts.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            errorMessage = "CoreData fetch error: \(error.localizedDescription)"
        }
    }

    private func saveToCoreData(categories: [Category], products: [Product]) {
        do {
            try deleteAll(entityName: "CategoryEntity")
            try deleteAll(entityName: "ProductEntity")

            for c in categories {
                let obj = NSEntityDescription.insertNewObject(forEntityName: "CategoryEntity", into: context)
                obj.setValue(Int64(c.id), forKey: "id")
                obj.setValue(c.name, forKey: "name")
            }

            for p in products {
                let obj = NSEntityDescription.insertNewObject(forEntityName: "ProductEntity", into: context)
                obj.setValue(Int64(p.id), forKey: "id")
                obj.setValue(p.name, forKey: "name")
                obj.setValue(p.price, forKey: "price")
                obj.setValue(Int64(p.categoryId), forKey: "categoryId")
            }

            try context.save()
        } catch {
            errorMessage = "CoreData save error: \(error.localizedDescription)"
        }
    }

    private func deleteAll(entityName: String) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        try context.execute(delete)
    }
}
