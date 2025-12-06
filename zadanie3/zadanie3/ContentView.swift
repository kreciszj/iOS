import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cartStore: CartStore

    var body: some View {
        TabView {
            ProductsListView()
                .tabItem {
                    Label("Produkty", systemImage: "list.bullet")
                }

            cartTab
                .tabItem {
                    Label("Koszyk", systemImage: "cart")
                }
        }
    }

    @ViewBuilder
    private var cartTab: some View {
        if cartStore.count > 0 {
            CartView()
                .badge(cartStore.count)
        } else {
            CartView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CartStore())
}
