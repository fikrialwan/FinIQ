import Foundation
import SwiftUI

@MainActor
@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false

    private let authService = AuthService.shared

    init() {
        isAuthenticated = KeychainManager.shared.hasValidToken
    }

    func login() async {
        guard validateLoginInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let tokens = try await authService.login(email: email, password: password)
            try KeychainManager.shared.saveTokens(tokens)
            isAuthenticated = true
            clearForm()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Login failed. Please try again."
        }

        isLoading = false
    }

    func register() async {
        guard validateRegisterInput() else { return }

        isLoading = true
        errorMessage = nil

        do {
            let tokens = try await authService.register(email: email, password: password)
            try KeychainManager.shared.saveTokens(tokens)
            isAuthenticated = true
            clearForm()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Registration failed. Please try again."
        }

        isLoading = false
    }

    func logout() {
        Task {
            await authService.logout()
        }
        isAuthenticated = false
        KeychainManager.shared.clearTokens()
    }

    func checkAuthStatus() {
        isAuthenticated = KeychainManager.shared.hasValidToken
    }

    private func validateLoginInput() -> Bool {
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        if !email.contains("@") {
            errorMessage = "Invalid email address"
            return false
        }
        if password.isEmpty {
            errorMessage = "Password is required"
            return false
        }
        return true
    }

    private func validateRegisterInput() -> Bool {
        if email.isEmpty {
            errorMessage = "Email is required"
            return false
        }
        if !email.contains("@") {
            errorMessage = "Invalid email address"
            return false
        }
        if password.count < 8 {
            errorMessage = "Password must be at least 8 characters"
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        return true
    }

    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }
}