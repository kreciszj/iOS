import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct ContentView: View {
    private let baseURL = "http://127.0.0.1:3000"
    private let githubClientID = "Ov23liWDaNn2RaidNXN9"

    @Environment(\.openURL) private var openURL

    @State private var email = ""
    @State private var password = ""

    @State private var token: String? = nil
    @State private var isLoading = false
    @State private var errorText: String? = nil
    @State private var infoText: String? = nil

    @State private var mode = 0

    @State private var ghUserCode: String? = nil
    @State private var ghVerificationURL: URL? = nil
    @State private var ghDeviceCode: String? = nil
    @State private var ghIntervalSeconds: Int = 5
    @State private var ghPollingTask: Task<Void, Never>? = nil

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
                        GIDSignIn.sharedInstance.signOut()
                        stopGitHubFlow()
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

                    if mode == 0 {
                        GoogleSignInButton(action: googleLogin)
                            .padding(.top, 6)
                            .disabled(isLoading)

                        Button {
                            Task { await startGitHubDeviceFlow() }
                        } label: {
                            Text("Zaloguj przez GitHub")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(isLoading || githubClientID.hasPrefix("TU_WKLEJ"))
                        .buttonStyle(.bordered)

                        if let code = ghUserCode, let url = ghVerificationURL {
                            VStack(spacing: 8) {
                                Text("GitHub Device Code:")
                                    .font(.headline)

                                Text(code)
                                    .font(.title)
                                    .bold()
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)

                                Button("Otwórz stronę GitHub") {
                                    openURL(url)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Anuluj") {
                                    stopGitHubFlow()
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.top, 8)
                        }
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Zadanie5")
            }
        }
    }

    private func googleLogin() {
        errorText = nil
        infoText = nil
        isLoading = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            errorText = "Brak aktywnego okna"
            isLoading = false
            return
        }

        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            errorText = "Brak rootViewController"
            isLoading = false
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorText = "Google: \(error.localizedDescription)"
                    return
                }

                guard let result = signInResult else {
                    self.errorText = "Google: brak wyniku logowania"
                    return
                }

                let idToken = result.user.idToken?.tokenString
                let accessToken = result.user.accessToken.tokenString

                self.token = (idToken?.isEmpty == false) ? idToken : accessToken
                self.infoText = "Google OK"
            }
        }
    }

    @MainActor
    private func startGitHubDeviceFlow() async {
        errorText = nil
        infoText = nil
        isLoading = true
        stopGitHubFlow()

        do {
            let resp = try await githubRequestDeviceCode()
            ghUserCode = resp.user_code
            ghDeviceCode = resp.device_code
            ghIntervalSeconds = max(resp.interval, 5)
            ghVerificationURL = URL(string: resp.verification_uri)

            isLoading = false
            infoText = "Otwórz GitHub i wpisz kod"

            ghPollingTask = Task {
                await pollGitHubForToken()
            }
        } catch {
            isLoading = false
            errorText = "GitHub: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func pollGitHubForToken() async {
        guard let deviceCode = ghDeviceCode else { return }

        while !Task.isCancelled {
            do {
                let res = try await githubPollAccessToken(deviceCode: deviceCode)

                if let accessToken = res.access_token, !accessToken.isEmpty {
                    self.token = accessToken
                    self.infoText = "GitHub OK"
                    stopGitHubFlow(keepUI: false)
                    return
                }

                if let err = res.error {
                    if err == "authorization_pending" {
                        try await Task.sleep(nanoseconds: UInt64(ghIntervalSeconds) * 1_000_000_000)
                        continue
                    }

                    if err == "slow_down" {
                        ghIntervalSeconds += 5
                        try await Task.sleep(nanoseconds: UInt64(ghIntervalSeconds) * 1_000_000_000)
                        continue
                    }

                    self.errorText = "GitHub: \(err)"
                    stopGitHubFlow(keepUI: true)
                    return
                }

                try await Task.sleep(nanoseconds: UInt64(ghIntervalSeconds) * 1_000_000_000)
            } catch {
                self.errorText = "GitHub: \(error.localizedDescription)"
                stopGitHubFlow(keepUI: true)
                return
            }
        }
    }

    private func stopGitHubFlow(keepUI: Bool = false) {
        ghPollingTask?.cancel()
        ghPollingTask = nil

        if !keepUI {
            ghUserCode = nil
            ghVerificationURL = nil
            ghDeviceCode = nil
            ghIntervalSeconds = 5
        }
    }

    private func formBody(_ dict: [String: String]) -> Data {
        let s = dict.map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(k)=\(v)"
        }.joined(separator: "&")
        return Data(s.utf8)
    }

    private func githubRequestDeviceCode() async throws -> GitHubDeviceCodeResponse {
        guard let url = URL(string: "https://github.com/login/device/code") else {
            throw NSError(domain: "BadURL", code: 0)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        request.httpBody = formBody([
            "client_id": githubClientID,
            "scope": "read:user user:email"
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "GitHubDeviceCode", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        return try JSONDecoder().decode(GitHubDeviceCodeResponse.self, from: data)
    }

    private func githubPollAccessToken(deviceCode: String) async throws -> GitHubAccessTokenResponse {
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            throw NSError(domain: "BadURL", code: 0)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        request.httpBody = formBody([
            "client_id": githubClientID,
            "device_code": deviceCode,
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let msg = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "GitHubAccessToken", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        return try JSONDecoder().decode(GitHubAccessTokenResponse.self, from: data)
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

struct GitHubDeviceCodeResponse: Codable {
    let device_code: String
    let user_code: String
    let verification_uri: String
    let expires_in: Int
    let interval: Int
}

struct GitHubAccessTokenResponse: Codable {
    let access_token: String?
    let token_type: String?
    let scope: String?
    let error: String?
    let error_description: String?
    let interval: Int?
}
