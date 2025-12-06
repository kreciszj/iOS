import SwiftUI
import CoreData

struct CartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var cartStore: CartStore

    private var cartProducts: [Product] {
        cartStore.products(in: viewContext)
    }

    private var totalPrice: Double {
        cartProducts.reduce(0) { partial, p in
            partial + (Double(cartStore.quantity(for: p)) * p.price)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if cartProducts.isEmpty {
                    VStack(spacing: 8) {
                        Text("Koszyk jest pusty")
                            .font(.headline)
                        Text("Dodaj produkty z zakładki Produkty.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                } else {
                    Section("Produkty w koszyku") {
                        ForEach(cartProducts) { p in
                            cartRow(for: p)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        cartStore.removeAll(of: p)
                                    } label: {
                                        Label("Usuń", systemImage: "trash")
                                    }
                                }
                        }
                    }

                    Section("Podsumowanie") {
                        HStack {
                            Text("Sztuki")
                            Spacer()
                            Text("\(cartStore.totalItemsCount)")
                                .monospacedDigit()
                        }

                        HStack {
                            Text("Suma")
                            Spacer()
                            Text("\(String(format: "%.2f", totalPrice)) zł")
                                .monospacedDigit()
                                .font(.headline)
                        }

                        Button(role: .destructive) {
                            cartStore.clear()
                        } label: {
                            Text("Wyczyść koszyk")
                        }
                    }
                }
            }
            .navigationTitle("Koszyk")
        }
    }

    @ViewBuilder
    private func cartRow(for product: Product) -> some View {
        let q = cartStore.quantity(for: product)
        let linePrice = Double(q) * product.price

        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name ?? "Bez nazwy")
                    .font(.headline)
                Text(product.category?.name ?? "Brak kategorii")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("Cena: \(String(format: "%.2f", product.price)) zł")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 10) {
                    Button {
                        cartStore.removeOne(product)
                    } label: {
                        Text("−")
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.bordered)

                    Text("\(q)")
                        .frame(minWidth: 24)
                        .monospacedDigit()

                    Button {
                        cartStore.add(product)
                    } label: {
                        Text("+")
                            .frame(width: 34, height: 34)
                    }
                    .buttonStyle(.bordered)
                }

                Text("\(String(format: "%.2f", linePrice)) zł")
                    .monospacedDigit()
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CartView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CartStore())
}
