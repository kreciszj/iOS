import SwiftUI

struct ContentView: View {
    @State private var fullName = ""
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var amount = "49.99"

    @State private var isLoading = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    private let serverURL = "http://127.0.0.1:8000/pay"

    var body: some View {
        NavigationStack {
            Form {
                Section("Dane płatności") {
                    TextField("Imię i nazwisko", text: $fullName)
                        .textInputAutocapitalization(.words)

                    TextField("Numer karty", text: $cardNumber)
                        .keyboardType(.numberPad)

                    TextField("MM/YY", text: $expiry)
                        .keyboardType(.numbersAndPunctuation)

                    SecureField("CVC", text: $cvc)
                        .keyboardType(.numberPad)

                    TextField("Kwota", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button {
                        payTapped()
                    } label: {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Zapłać")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Płatność")
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func payTapped() {
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            show(title: "Błąd", message: "Podaj imię i nazwisko")
            return
        }
        if cardNumber.filter({ $0.isNumber }).count < 12 {
            show(title: "Błąd", message: "Numer karty za krótki")
            return
        }
        if expiry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            show(title: "Błąd", message: "Podaj datę ważności")
            return
        }
        if cvc.filter({ $0.isNumber }).count < 3 {
            show(title: "Błąd", message: "CVC za krótki")
            return
        }

        isLoading = true

        Task {
            do {
                let response = try await sendPayment()
                await MainActor.run {
                    isLoading = false
                    if response.status == "success" {
                        show(title: "Sukces", message: "Płatność zaakceptowana.\nTransaction ID: \(response.transaction_id)")
                    } else {
                        show(title: "Odrzucono", message: "Płatność odrzucona.\nPowód: \(response.message)")
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    show(title: "Błąd sieci", message: "Nie udało się połączyć z serwerem.\n\(error.localizedDescription)")
                }
            }
        }
    }

    private func sendPayment() async throws -> PayResponse {
        guard let url = URL(string: serverURL) else {
            throw URLError(.badURL)
        }

        let requestBody = PayRequest(
            full_name: fullName,
            card_number: cardNumber,
            expiry: expiry,
            cvc: cvc,
            amount: amount
        )

        let data = try JSONEncoder().encode(requestBody)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        let (responseData, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(PayResponse.self, from: responseData)
    }

    private func show(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct PayRequest: Codable {
    let full_name: String
    let card_number: String
    let expiry: String
    let cvc: String
    let amount: String
}

struct PayResponse: Codable {
    let status: String
    let transaction_id: String
    let message: String
}


#Preview {
    ContentView()
}
