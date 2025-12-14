import Foundation
import Combine
import CoreData

@MainActor
final class Store: ObservableObject {
    @Published var categories: [Category] = []
    @Published var products: [Product] = []
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let api = APIClient()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadFromCoreData()
    }

    func load() async {
        if categories.isEmpty && products.isEmpty && orders.isEmpty {
            loadFromCoreData()
        }

        isLoading = true
        errorMessage = nil

        do {
            async let cats = api.fetchCategories()
            async let prods = api.fetchProducts()
            async let ords = api.fetchOrders()

            let (c, p, o) = try await (cats, prods, ords)

            let sortedC = c.sorted { $0.name.lowercased() < $1.name.lowercased() }
            let sortedP = p.sorted { $0.name.lowercased() < $1.name.lowercased() }
            let sortedO = o.sorted { $0.createdAt > $1.createdAt }

            categories = sortedC
            products = sortedP
            orders = sortedO

            saveToCoreData(categories: sortedC, products: sortedP, orders: sortedO)
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
            let orderReq = NSFetchRequest<NSManagedObject>(entityName: "OrderEntity")

            let catObjects = try context.fetch(catReq)
            let prodObjects = try context.fetch(prodReq)
            let orderObjects = try context.fetch(orderReq)

            let loadedCategories: [Category] = catObjects.compactMap { obj in
                let id = obj.value(forKey: "id") as? Int64 ?? 0
                let name = obj.value(forKey: "name") as? String ?? ""
                return Category(id: Int(id), name: name)
            }

            let loadedProducts: [Product] = prodObjects.compactMap { obj in
                let id = obj.value(forKey: "id") as? Int64 ?? 0
                let name = obj.value(forKey: "name") as? String ?? ""
                let price = obj.value(forKey: "price") as? Double ?? 0
                let categoryId = obj.value(forKey: "categoryId") as? Int64 ?? 0
                return Product(id: Int(id), name: name, price: price, categoryId: Int(categoryId))
            }

            let loadedOrders: [Order] = orderObjects.compactMap { obj in
                let id = obj.value(forKey: "id") as? Int64 ?? 0
                let customerName = obj.value(forKey: "customerName") as? String ?? ""
                let createdAt = obj.value(forKey: "createdAt") as? String ?? ""
                let status = obj.value(forKey: "status") as? String ?? ""
                let note = obj.value(forKey: "note") as? String ?? ""

                let itemsSet = obj.value(forKey: "items") as? Set<NSManagedObject> ?? []
                let items: [OrderItem] = itemsSet.compactMap { it in
                    let itemId = it.value(forKey: "id") as? Int64 ?? 0
                    let productId = it.value(forKey: "productId") as? Int64 ?? 0
                    let quantity = it.value(forKey: "quantity") as? Int64 ?? 0
                    let unitPrice = it.value(forKey: "unitPrice") as? Double ?? 0
                    return OrderItem(id: Int(itemId), productId: Int(productId), quantity: Int(quantity), unitPrice: unitPrice)
                }.sorted { $0.id < $1.id }

                return Order(id: Int(id), customerName: customerName, createdAt: createdAt, status: status, note: note, items: items)
            }

            categories = loadedCategories.sorted { $0.name.lowercased() < $1.name.lowercased() }
            products = loadedProducts.sorted { $0.name.lowercased() < $1.name.lowercased() }
            orders = loadedOrders.sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "CoreData fetch error: \(error.localizedDescription)"
        }
    }

    private func saveToCoreData(categories: [Category], products: [Product], orders: [Order]) {
        do {
            try deleteAll(entityName: "CategoryEntity")
            try deleteAll(entityName: "ProductEntity")
            try deleteAll(entityName: "OrderItemEntity")
            try deleteAll(entityName: "OrderEntity")

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

            for o in orders {
                let orderObj = NSEntityDescription.insertNewObject(forEntityName: "OrderEntity", into: context)
                orderObj.setValue(Int64(o.id), forKey: "id")
                orderObj.setValue(o.customerName, forKey: "customerName")
                orderObj.setValue(o.createdAt, forKey: "createdAt")
                orderObj.setValue(o.status, forKey: "status")
                orderObj.setValue(o.note, forKey: "note")

                let set = orderObj.mutableSetValue(forKey: "items")
                for it in o.items {
                    let itemObj = NSEntityDescription.insertNewObject(forEntityName: "OrderItemEntity", into: context)
                    itemObj.setValue(Int64(it.id), forKey: "id")
                    itemObj.setValue(Int64(it.productId), forKey: "productId")
                    itemObj.setValue(Int64(it.quantity), forKey: "quantity")
                    itemObj.setValue(it.unitPrice, forKey: "unitPrice")
                    itemObj.setValue(orderObj, forKey: "order")
                    set.add(itemObj)
                }
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
