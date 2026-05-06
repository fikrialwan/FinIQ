import Foundation

@MainActor
@Observable
final class TransactionViewModel {
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    var selectedTransaction: Transaction?

    // Form fields
    var amount = ""
    var type: TransactionType = .expense
    var selectedAccountId: String?
    var selectedCategoryId: String?
    var note = ""
    var date = Date()

    private let apiClient = APIClient.shared

    func loadTransactions() async {
        isLoading = true
        errorMessage = nil

        do {
            async let transactionsTask: [Transaction] = apiClient.request(.getTransactions)
            async let categoriesTask: [Category] = apiClient.request(.getCategories)
            async let accountsTask: [Account] = apiClient.request(.getAccounts)

            let (fetchedTransactions, fetchedCategories, fetchedAccounts) = try await (transactionsTask, categoriesTask, accountsTask)

            transactions = fetchedTransactions
            categories = fetchedCategories
            accounts = fetchedAccounts
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load transactions"
        }

        isLoading = false
    }

    func createTransaction() async -> Bool {
        guard let accountId = selectedAccountId, !amount.isEmpty else {
            errorMessage = "Please select an account and enter an amount"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let dateFormatter = ISO8601DateFormatter()
            let dateString = dateFormatter.string(from: date)

            let newTransaction: Transaction = try await apiClient.request(
                .createTransaction(
                    accountId: accountId,
                    amount: amount,
                    type: type,
                    categoryId: selectedCategoryId,
                    note: note.isEmpty ? nil : note,
                    date: dateString
                )
            )

            // If expense, apply round-up to General Savings
            if type == .expense {
                await applyRoundUp()
            }

            transactions.insert(newTransaction, at: 0)
            resetForm()
            isLoading = false
            NotificationCenter.default.post(name: .transactionDidChange, object: nil)
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to create transaction"
        }

        isLoading = false
        return false
    }

    func deleteTransaction(_ transaction: Transaction) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteTransaction(id: transaction.id))
            transactions.removeAll { $0.id == transaction.id }
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to delete transaction"
        }

        isLoading = false
        return false
    }

    private func applyRoundUp() async {
        guard let amountDecimal = Decimal(string: amount) else { return }

        let amountDouble = NSDecimalNumber(decimal: amountDecimal).doubleValue
        let roundedUp = ceil(amountDouble)
        let roundUpAmount = Decimal(roundedUp) - amountDecimal

        guard roundUpAmount > 0 else { return }

        // Find or create General Savings goal
        do {
            let goals: [Goal] = try await apiClient.request(.getGoals)
            if let generalSavings = goals.first(where: { $0.name == "General Savings" }),
               let accountId = selectedAccountId {
                let _: Goal = try await apiClient.request(
                    .depositToGoal(
                        id: generalSavings.id,
                        amount: "\(roundUpAmount)",
                        fromAccountId: accountId
                    )
                )
            }
        } catch {
            // Silently fail round-up - not critical
        }
    }

    func resetForm() {
        amount = ""
        type = .expense
        selectedAccountId = nil
        selectedCategoryId = nil
        note = ""
        date = Date()
        selectedTransaction = nil
    }

    var filteredCategories: [Category] {
        categories.filter { $0.type == (type == .income ? .income : .expense) }
    }

    func loadCategories() async {
        do {
            categories = try await apiClient.request(.getCategories)
        } catch {
            // categories stay empty on failure
        }
    }

    func createCategory(name: String, type: CategoryType, icon: String?) async -> Category? {
        do {
            let newCategory: Category = try await apiClient.request(.createCategory(name: name, type: type, icon: icon))
            categories.append(newCategory)
            return newCategory
        } catch {
            return nil
        }
    }
}