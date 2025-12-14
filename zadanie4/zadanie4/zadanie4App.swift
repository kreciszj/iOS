import SwiftUI
import CoreData

@main
struct zadanie4App: App {
    private let persistence = PersistenceController.shared
    @StateObject private var store: Store

    init() {
        let context = persistence.container.viewContext
        _store = StateObject(wrappedValue: Store(context: context))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(store)
        }
    }
}
