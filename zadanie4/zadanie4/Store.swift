import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var categories: [Category] = []
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let api = APIClient()

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let cats = api.fetchCategories()
            async let prods = api.fetchProducts()
            let (c, p) = try await (cats, prods)

            categories = c.sorted { $0.name.lowercased() < $1.name.lowercased() }
            products = p.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            categories = []
            products = []
        }

        isLoading = false
    }

    func categoryName(for product: Product) -> String {
        categories.first(where: { $0.id == product.categoryId })?.name ?? "Brak"
    }
}
