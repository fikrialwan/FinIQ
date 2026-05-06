import Foundation

@MainActor
@Observable
final class AccountViewModel {
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    var selectedAccount: Account?
    var showAddAccount = false
    var showEditAccount = false

    private let apiClient = APIClient.shared

    // Form fields
    var name = ""
    var type: AccountType = .bank
    var balance = ""

    func loadAccounts() async {
        isLoading = true
        errorMessage = nil

        do {
            accounts = try await apiClient.request(.getAccounts)
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load accounts"
        }

        isLoading = false
    }

    func createAccount() async -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Account name is required"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let newAccount: Account = try await apiClient.request(
                .createAccount(name: name, type: type, balance: balance.isEmpty ? nil : balance)
            )
            accounts.append(newAccount)
            resetForm()
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to create account"
        }

        isLoading = false
        return false
    }

    func updateAccount() async -> Bool {
        guard let account = selectedAccount else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let updated: Account = try await apiClient.request(
                .updateAccount(id: account.id, name: name.isEmpty ? nil : name, type: type, balance: balance.isEmpty ? nil : balance)
            )

            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index] = updated
            }
            resetForm()
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to update account"
        }

        isLoading = false
        return false
    }

    func deleteAccount(_ account: Account) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteAccount(id: account.id))
            accounts.removeAll { $0.id == account.id }
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to delete account"
        }

        isLoading = false
        return false
    }

    func editAccount(_ account: Account) {
        selectedAccount = account
        name = account.name
        type = account.type
        balance = account.balance
        showEditAccount = true
    }

    func resetForm() {
        name = ""
        type = .bank
        balance = ""
        selectedAccount = nil
        showAddAccount = false
        showEditAccount = false
    }
}