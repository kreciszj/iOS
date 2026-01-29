import SwiftUI

@main
struct zadanie6App: App {
    @StateObject private var paymentStore = PaymentStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paymentStore)
        }
    }
}
