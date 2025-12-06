import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default
    )
    private var products: FetchedResults<Product>

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Zad 3")
                    .font(.headline)

                VStack(spacing: 6) {
                    Text("Liczba kategorii: \(categories.count)")
                    Text("Liczba produktów: \(products.count)")
                }
                .font(.subheadline)
                Spacer()
            }
            .padding()
            .navigationTitle("Lista zakupow")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
