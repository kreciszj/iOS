import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        TabView {
            CategoriesView()
                .tabItem { Text("Kategorie") }

            ProductsView()
                .tabItem { Text("Produkty") }
        }
        .task {
            await store.load()
        }
    }
}

struct CategoriesView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationStack {
            List {
                if store.isLoading {
                    HStack {
                        ProgressView()
                        Text("Pobieranie danych")
                    }
                }

                if let error = store.errorMessage {
                    Section("Info") {
                        Text(error).foregroundStyle(.red)
                        Text("Stale mode")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Kategorie (\(store.categories.count))") {
                    if store.categories.isEmpty && !store.isLoading {
                        Text("Brak danych").foregroundStyle(.secondary)
                    } else {
                        ForEach(store.categories) { c in
                            Text(c.name)
                        }
                    }
                }
            }
            .navigationTitle("Kategorie")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task { await store.load() }
                    }
                }
            }
        }
    }
}

struct ProductsView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationStack {
            List {
                if store.isLoading {
                    HStack {
                        ProgressView()
                        Text("Pobieranie danych")
                    }
                }

                if let error = store.errorMessage {
                    Section("Info") {
                        Text(error).foregroundStyle(.red)
                        Text("Stale mode")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Produkty (\(store.products.count))") {
                    if store.products.isEmpty && !store.isLoading {
                        Text("Brak danych").foregroundStyle(.secondary)
                    } else {
                        ForEach(store.products) { p in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.name).font(.headline)
                                Text("Cena: \(p.price, specifier: "%.2f") | \(store.categoryName(for: p))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Produkty")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task { await store.load() }
                    }
                }
            }
        }
    }
}
