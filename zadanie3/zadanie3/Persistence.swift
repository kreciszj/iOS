import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private static func detectModelName() -> String {
        if let url = Bundle.main.urls(forResourcesWithExtension: "momd", subdirectory: nil)?.first {
            return url.deletingPathExtension().lastPathComponent
        }
        return "Model"
    }

    init(inMemory: Bool = false) {
        let modelName = Self.detectModelName()
        container = NSPersistentContainer(name: modelName)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data load error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func loadFixturesIfNeeded() {
        let context = container.viewContext

        let categoryCount = (try? context.count(for: Category.fetchRequest())) ?? 0
        let productCount = (try? context.count(for: Product.fetchRequest())) ?? 0

        if categoryCount > 0 || productCount > 0 {
            return
        }


        let bread = Category(context: context)
        bread.id = UUID()
        bread.name = "Pieczywo"

        let veggies = Category(context: context)
        veggies.id = UUID()
        veggies.name = "Warzywa"

        let household = Category(context: context)
        household.id = UUID()
        household.name = "Dom"

        func addProduct(name: String, details: String?, price: Double, category: Category) {
            let p = Product(context: context)
            p.id = UUID()
            p.name = name
            p.details = details
            p.price = price
            p.category = category
        }

        addProduct(name: "Chleb żytni",
                   details: "Krojony",
                   price: 7.50,
                   category: bread)

        addProduct(name: "kajzerki",
                   details: "4",
                   price: 2.80,
                   category: bread)

        addProduct(name: "Pomidory",
                   details: "0.5 kg",
                   price: 8.00,
                   category: veggies)

        addProduct(name: "ogorek",
                   details: "200g",
                   price: 2.49,
                   category: veggies)

        addProduct(name: "Płyn do naczyń",
                   details: "",
                   price: 6.12,
                   category: household)

        addProduct(name: "Papier toaletowy",
                   details: "8 rolek",
                   price: 11.29,
                   category: household)

        do {
            try context.save()
        } catch {
            context.rollback()
            print("Fixtures save error: \(error)")
        }
    }

    static var preview: PersistenceController = {
        let pc = PersistenceController(inMemory: true)
        pc.loadFixturesIfNeeded()
        return pc
    }()
}
