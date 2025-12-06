import SwiftUI
import CoreData

struct CartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var cartStore: CartStore

    private var cartProducts: [Product] {
        cartStore.products(in: viewContext)
    }

    private var totalPrice: Double {
        cartProducts.reduce(0) { $0 + $1.price }
    }

    var body: some View {
        NavigationStack {
            List {
                if cartProducts.isEmpty {
                    VStack(spacing: 8) {
                        Text("Koszyk jest pusty")
                            .font(.headline)
                        Text("Dodaj produkt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                } else {
                    Section("Produkty w koszyku") {
                        ForEach(cartProducts) { p in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(p.name ?? "Bez nazwy")
                                        .font(.headline)
                                    Text(p.category?.name ?? "Brak kategorii")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.2f zł", p.price))
                                    .monospacedDigit()
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: delete)
                    }

                    Section("Podsumowanie") {
                        Text("Suma: \(String(format: "%.2f", totalPrice)) zł")
                            .font(.headline)

                        Button(role: .destructive) {
                            cartStore.clear()
                        } label: {
                            Text("Wyczyść")
                        }
                    }
                }
            }
            .navigationTitle("Koszyk")
            .toolbar {
                if !cartProducts.isEmpty {
                    EditButton()
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        let items = cartProducts
        for index in offsets {
            cartStore.remove(items[index])
        }
    }
}

#Preview {
    CartView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CartStore())
}
