import SwiftUI
import CoreData

struct ProductDetailsView: View {
    let product: Product
    @EnvironmentObject private var cartStore: CartStore

    var body: some View {
        Form {
            Section("Nazwa") {
                Text(product.name ?? "Bez nazwy")
                    .font(.headline)
            }

            Section("Opis") {
                let d = (product.details ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if d.isEmpty {
                    Text("Brak opisu")
                        .foregroundStyle(.secondary)
                } else {
                    Text(d)
                }
            }

            Section("Cena") {
                Text(String(format: "%.2f zł", product.price))
                    .monospacedDigit()
            }

            Section("Kategoria") {
                Text(product.category?.name ?? "Brak kategorii")
            }

            Section("Koszyk") {
                let q = cartStore.quantity(for: product)

                HStack {
                    Text("Ilość w koszyku")
                    Spacer()
                    Text("\(q)")
                        .monospacedDigit()
                }

                HStack(spacing: 12) {
                    Button {
                        cartStore.removeOne(product)
                    } label: {
                        Text("−")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .disabled(q == 0)

                    Button {
                        cartStore.add(product)
                    } label: {
                        Text("Dodaj do koszyka")
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        cartStore.add(product)
                    } label: {
                        Text("+")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .navigationTitle("Szczegóły")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let pc = PersistenceController.preview
    let ctx = pc.container.viewContext
    let req: NSFetchRequest<Product> = Product.fetchRequest()
    req.fetchLimit = 1
    let first = (try? ctx.fetch(req))?.first

    return NavigationStack {
        ProductDetailsView(product: first ?? Product(context: ctx))
            .environmentObject(CartStore())
    }
}
