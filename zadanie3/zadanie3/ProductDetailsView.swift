import SwiftUI
import CoreData

struct ProductDetailsView: View {
    let product: Product

    var body: some View {
        Form {
            Section("Nazwa") {
                Text(product.name ?? "Brak nazwy")
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
    }
}
