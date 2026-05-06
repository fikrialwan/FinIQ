import Foundation
import SwiftUI

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var currencyPref = "IDR"
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false

    private let apiClient = APIClient.shared
    private let keychain = KeychainManager.shared
    private let biometric = BiometricAuth.shared

    init() {
        checkExistingSession()
    }

    var isLoginValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 8
    }

    var isRegisterValid: Bool {
        isLoginValid && password == confirmPassword && password.count >= 8
    }

    var biometricType: BiometricAuth.BiometricType {
        biometric.biometricType
    }

    var isBiometricAvailable: Bool {
        biometric.isBiometricAvailable
    }

    private func checkExistingSession() {
        if let token = keychain.getToken(for: Config.accessTokenKey), !token.isEmpty {
            isAuthenticated = true
        }
    }

    func login() async {
        guard isLoginValid else {
            errorMessage = "Please enter a valid email and password (min 8 characters)"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let tokens: AuthTokens = try await apiClient.request(.login(email: email, password: password))
            try keychain.saveToken(tokens.accessToken, for: Config.accessTokenKey)
            try keychain.saveToken(tokens.refreshToken, for: Config.refreshTokenKey)
            try keychain.saveToken(tokens.expiresAt, for: Config.tokenExpiryKey)
            isAuthenticated = true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Login failed. Please try again."
        }

        isLoading = false
    }

    func register() async {
        guard isRegisterValid else {
            if password != confirmPassword {
                errorMessage = "Passwords do not match"
            } else {
                errorMessage = "Please enter a valid email and password (min 8 characters)"
            }
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let tokens: AuthTokens = try await apiClient.request(
                .register(email: email, password: password, currencyPref: currencyPref)
            )
            try keychain.saveToken(tokens.accessToken, for: Config.accessTokenKey)
            try keychain.saveToken(tokens.refreshToken, for: Config.refreshTokenKey)
            try keychain.saveToken(tokens.expiresAt, for: Config.tokenExpiryKey)
            isAuthenticated = true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Registration failed. Please try again."
        }

        isLoading = false
    }

    func authenticateWithBiometric() async {
        do {
            let success = try await biometric.authenticate()
            if success {
                isAuthenticated = true
            }
        } catch let error as BiometricError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Biometric authentication failed"
        }
    }

    func logout() {
        keychain.clearTokens()
        isAuthenticated = false
        email = ""
        password = ""
        confirmPassword = ""
    }
}