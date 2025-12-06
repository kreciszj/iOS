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

    static var preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()
}
