import Foundation
import SwiftUI

@MainActor
@Observable
final class AccountViewModel {
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    private let accountService = AccountService.shared

    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balanceDouble }
    }

    func loadAccounts() async {
        isLoading = true
        errorMessage = nil

        do {
            accounts = try await accountService.getAccounts()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load accounts"
        }

        isLoading = false
    }

    func createAccount(name: String, type: AccountType, balance: String?) async -> Bool {
        do {
            let account = try await accountService.createAccount(name: name, type: type, balance: balance)
            accounts.append(account)
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to create account"
            return false
        }
    }

    func updateAccount(id: String, name: String?, type: AccountType?, balance: String?) async -> Bool {
        do {
            let updated = try await accountService.updateAccount(id: id, name: name, type: type, balance: balance)
            if let index = accounts.firstIndex(where: { $0.id == id }) {
                accounts[index] = updated
            }
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to update account"
            return false
        }
    }

    func deleteAccount(id: String) async -> Bool {
        do {
            try await accountService.deleteAccount(id: id)
            accounts.removeAll { $0.id == id }
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to delete account"
            return false
        }
    }

    func refresh() async {
        await loadAccounts()
    }
}