import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CategoriesView()
                .tabItem { Text("Kategorie") }

            ProductsView()
                .tabItem { Text("Produkty") }
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
                        Text("cache z coredata jak siec padnie")
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
                    Button("Refresh") { Task { await store.load() } }
                }
            }
            .task { await store.load() }
        }
    }
}

struct ProductsView: View {
    @EnvironmentObject private var store: Store
    @State private var showAdd = false

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
                        Text("jak siec padnie to nie doda, ale cache zostaje")
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Refresh") { Task { await store.load() } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("+") { showAdd = true }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddProductView()
            }
            .task { await store.load() }
        }
    }
}

struct AddProductView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var selectedCategoryId: Int = 0

    private var priceValue: Double? {
        let t = priceText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(t)
    }

    private var canSave: Bool {
        let okName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let okPrice = (priceValue ?? 0) > 0
        let okCat = !store.categories.isEmpty
        return okName && okPrice && okCat && !store.isLoading
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nowy produkt") {
                    TextField("Nazwa", text: $name)
                    TextField("Cena", text: $priceText)
                        .keyboardType(.decimalPad)

                    if store.categories.isEmpty {
                        Text("Brak kategorii, zrob refresh")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Kategoria", selection: $selectedCategoryId) {
                            Text("Wybierz").tag(0)
                            ForEach(store.categories) { c in
                                Text(c.name).tag(c.id)
                            }
                        }
                    }
                }

                if let error = store.errorMessage {
                    Section("Info") {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Dodaj produkt")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") {
                        guard let price = priceValue else { return }
                        let catId = selectedCategoryId != 0 ? selectedCategoryId : (store.categories.first?.id ?? 0)
                        if catId == 0 { return }

                        Task {
                            await store.addProduct(name: name, price: price, categoryId: catId)
                            if store.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if store.categories.isEmpty {
                    Task { await store.load() }
                } else if selectedCategoryId == 0 {
                    selectedCategoryId = store.categories.first?.id ?? 0
                }
            }
            .onChange(of: store.categories) { _, newValue in
                if selectedCategoryId == 0 {
                    selectedCategoryId = newValue.first?.id ?? 0
                }
            }
        }
    }
}
