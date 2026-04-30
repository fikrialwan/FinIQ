import Foundation
import SwiftUI

@MainActor
@Observable
final class ActivityViewModel {
    var transactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    var accounts: [Account] = []
    var categories: [Category] = []
    var searchText = ""
    var selectedAccountId: String?
    var selectedType: TransactionType?
    var isLoading = false
    var errorMessage: String?

    private let transactionService = TransactionService.shared
    private let accountService = AccountService.shared
    private let categoryService = CategoryService.shared

    var displayTransactions: [Transaction] {
        filteredTransactions.isEmpty && searchText.isEmpty ? transactions : filteredTransactions
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let transactionsTask = transactionService.getTransactions()
            async let accountsTask = accountService.getAccounts()
            async let categoriesTask = categoryService.getCategories()

            let (fetchedTransactions, fetchedAccounts, fetchedCategories) = try await (transactionsTask, accountsTask, categoriesTask)

            self.transactions = fetchedTransactions
            self.accounts = fetchedAccounts
            self.categories = fetchedCategories
            applyFilters()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load transactions"
        }

        isLoading = false
    }

    func addTransaction(
        accountId: String,
        amount: String,
        type: TransactionType,
        categoryId: String?,
        note: String?,
        date: String?
    ) async -> Bool {
        do {
            let transaction = try await transactionService.createTransaction(
                accountId: accountId,
                amount: amount,
                type: type,
                categoryId: categoryId,
                note: note,
                date: date
            )
            transactions.insert(transaction, at: 0)
            applyFilters()
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to create transaction"
            return false
        }
    }

    func deleteTransaction(id: String) async -> Bool {
        do {
            try await transactionService.deleteTransaction(id: id)
            transactions.removeAll { $0.id == id }
            applyFilters()
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to delete transaction"
            return false
        }
    }

    func filterBySearch(_ text: String) {
        searchText = text
        applyFilters()
    }

    func filterByAccount(_ accountId: String?) {
        selectedAccountId = accountId
        applyFilters()
    }

    func filterByType(_ type: TransactionType?) {
        selectedType = type
        applyFilters()
    }

    func clearFilters() {
        searchText = ""
        selectedAccountId = nil
        selectedType = nil
        filteredTransactions = []
    }

    private func applyFilters() {
        var result = transactions

        if !searchText.isEmpty {
            result = result.filter {
                $0.note?.localizedCaseInsensitiveContains(searchText) == true ||
                $0.category?.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        if let accountId = selectedAccountId {
            result = result.filter { $0.accountId == accountId }
        }

        if let type = selectedType {
            result = result.filter { $0.type == type }
        }

        filteredTransactions = result
    }

    func refresh() async {
        await loadData()
    }
}