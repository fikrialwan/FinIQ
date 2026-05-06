import Foundation

@MainActor
@Observable
final class TransferViewModel {
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    var fromAccountId: String?
    var toAccountId: String?
    var amount = ""
    var note = ""
    var date = Date()

    private let apiClient = APIClient.shared

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

    func createTransfer() async -> Bool {
        guard let fromId = fromAccountId, let toId = toAccountId else {
            errorMessage = "Please select both accounts"
            return false
        }

        guard fromId != toId else {
            errorMessage = "Cannot transfer to the same account"
            return false
        }

        guard !amount.isEmpty else {
            errorMessage = "Please enter an amount"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let dateFormatter = ISO8601DateFormatter()
            let dateString = dateFormatter.string(from: date)

            let _: TransferResponse = try await apiClient.request(
                .createTransfer(
                    fromAccountId: fromId,
                    toAccountId: toId,
                    amount: amount,
                    note: note.isEmpty ? nil : note,
                    date: dateString
                )
            )

            resetForm()
            isLoading = false
            NotificationCenter.default.post(name: .transactionDidChange, object: nil)
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to create transfer"
        }

        isLoading = false
        return false
    }

    func resetForm() {
        fromAccountId = nil
        toAccountId = nil
        amount = ""
        note = ""
        date = Date()
    }
}