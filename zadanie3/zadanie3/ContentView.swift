import SwiftUI
import CoreData

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Product.name, ascending: true)
        ],
        animation: .default
    )
    private var products: FetchedResults<Product>

    var body: some View {
        NavigationStack {
            List {
                if products.isEmpty {
                    ContentUnavailableView("Brak produktów", systemImage: "cart", description: Text("Nie znaleziono danych w Core Data."))
                } else {
                    ForEach(products) { p in
                        NavigationLink {
                            ProductDetailsView(product: p)
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(p.name ?? "Brak nazwy")
                                        .font(.headline)

                                    Text(p.category?.name ?? "Brak kategorii")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(String(format: "%.2f zł", p.price))
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Produkty")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
