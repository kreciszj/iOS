import SwiftUI

struct PurchasesView: View {
    @EnvironmentObject var store: PaymentStore

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        List {
            if store.payments.isEmpty {
                Text("Brak opłaconych zakupów")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
            } else {
                ForEach(store.payments) { p in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(p.fullName)
                                .font(.headline)
                            Spacer()
                            Text(p.amount)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Text("\(p.maskedCard) • \(Self.dateFormatter.string(from: p.date))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Transaction ID: \(p.transactionID)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding(.vertical, 6)
                }
                .onDelete(perform: store.remove)
            }
        }
        .navigationTitle("Zakupy")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !store.payments.isEmpty {
                    Button("Wyczyść") {
                        withAnimation {
                            store.clear()
                        }
                    }
                }
            }
        }
    }
}

struct PurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = PaymentStore()
        store.add(Payment(fullName: "Jan Kowalski", cardLast4: "4242", amount: "49.99", transactionID: "demo-123"))
        return NavigationStack {
            PurchasesView()
                .environmentObject(store)
        }
    }
}
