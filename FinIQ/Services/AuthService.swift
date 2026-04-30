import Foundation

actor AuthService {
    static let shared = AuthService()

    private let client = APIClient.shared

    func login(email: String, password: String) async throws -> AuthTokens {
        let request = LoginRequest(email: email, password: password)
        return try await client.request(
            endpoint: "/auth/login",
            method: .post,
            body: request,
            requiresAuth: false
        )
    }

    func register(email: String, password: String, currencyPref: String? = nil) async throws -> AuthTokens {
        let request = RegisterRequest(email: email, password: password, currencyPref: currencyPref)
        return try await client.request(
            endpoint: "/auth/register",
            method: .post,
            body: request,
            requiresAuth: false
        )
    }

    func refresh(token: String) async throws -> AuthTokens {
        let request = RefreshRequest(token: token)
        return try await client.request(
            endpoint: "/auth/refresh",
            method: .post,
            body: request,
            requiresAuth: false
        )
    }

    func logout() {
        KeychainManager.shared.clearTokens()
    }
}