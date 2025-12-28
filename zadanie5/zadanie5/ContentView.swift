import SwiftUI

struct ContentView: View {
    private let baseURL = "http://127.0.0.1:3000"

    @State private var email = ""
    @State private var password = ""

    @State private var token: String? = nil
    @State private var isLoading = false
    @State private var errorText: String? = nil
    @State private var infoText: String? = nil

    @State private var mode = 0

    var body: some View {
        NavigationView {
            if let token {
                VStack(spacing: 16) {
                    Text("Zalogowano")
                        .font(.title2)
                        .bold()

                    Text("Token:")
                        .font(.headline)

                    Text(token)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    Button("Wyloguj") {
                        self.token = nil
                        self.password = ""
                        self.errorText = nil
                        self.infoText = nil
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }
                .padding()
                .navigationTitle("Zadanie5")
            } else {
                VStack(spacing: 12) {
                    Picker("", selection: $mode) {
                        Text("Logowanie").tag(0)
                        Text("Rejestracja").tag(1)
                    }
                    .pickerStyle(.segmented)

                    Text(mode == 0 ? "Logowanie" : "Rejestracja")
                        .font(.title2)
                        .bold()
                        .padding(.top, 6)

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Haslo", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if let infoText {
                        Text(infoText)
                            .foregroundColor(.green)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    if let errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            if mode == 0 {
                                await login()
                            } else {
                                await register()
                            }
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text(mode == 0 ? "Zaloguj" : "Zarejestruj")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }
                .padding()
                .navigationTitle("Zadanie5")
            }
        }
    }

    @MainActor
    private func register() async {
        errorText = nil
        infoText = nil
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/register") else {
            errorText = "Zły adres serwera."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = AuthRequest(email: email, password: password)

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? ""
                errorText = "Błąd rejestracji (\(http.statusCode)). \(msg)"
                return
            }

            infoText = "Konto utworzone. Możesz się zalogować."
            password = ""
            mode = 0
        } catch {
            errorText = "Nie udało się zarejestrować: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func login() async {
        errorText = nil
        infoText = nil
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/login") else {
            errorText = "Zły adres serwera"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = AuthRequest(email: email, password: password)

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? ""
                errorText = "Blad logowania (\(http.statusCode)). \(msg)"
                return
            }

            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            token = decoded.token
        } catch {
            errorText = "Nie udało sie zalogowac: \(error.localizedDescription)"
        }
    }
}

struct AuthRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
}
