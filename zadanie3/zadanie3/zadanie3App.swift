import SwiftUI
import CoreData

@main
struct zadanie3App: App {
    private let persistenceController = PersistenceController.shared
    @StateObject private var cartStore = CartStore()

    init() {
        persistenceController.loadFixturesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(cartStore)
        }
    }
}
