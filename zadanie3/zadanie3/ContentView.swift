import SwiftUI
import CoreData

struct ContentView: View {
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
            List {
                Section("Podsumowanie") {
                    Text("Liczba kategorii: \(categories.count)")
                    Text("Liczba produktów: \(products.count)")
                }

                Section("Kategorie") {
                    if categories.isEmpty {
                        Text("Brak danych")
                    } else {
                        ForEach(categories) { c in
                            Text(c.name ?? "Brak Nazwy")
                        }
                    }
                }

                Section("Produkty") {
                    if products.isEmpty {
                        Text("Brak danych")
                    } else {
                        ForEach(products) { p in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.name ?? "Bez nazwy")
                                    .font(.headline)

                                if let d = p.details, !d.isEmpty {
                                    Text(d)
                                        .font(.subheadline)
                                }

                                Text(String(format: "%.2f zł", p.price))
                                    .font(.footnote)

                                Text("Kategoria: \(p.category?.name ?? "brak")")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Lista zakupow")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
