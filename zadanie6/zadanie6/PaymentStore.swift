import Foundation
import Combine
import SwiftUI

final class PaymentStore: ObservableObject {
    @Published private(set) var payments: [Payment] = []

    private let filename = "payments.json"
    private var fileURL: URL {
        let fm = FileManager.default
        let docs = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return docs.appendingPathComponent(filename)
    }

    init() {
        load()
    }

    func add(_ payment: Payment) {
        payments.insert(payment, at: 0)
        save()
    }

    func remove(at offsets: IndexSet) {
        payments.remove(atOffsets: offsets)
        save()
    }

    func clear() {
        payments.removeAll()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(payments)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("PaymentStore save error:", error)
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Payment].self, from: data)
            payments = decoded
        } catch {
            payments = []
        }
    }
}
