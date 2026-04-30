import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var summary: AnalyticsSummary?
    var accounts: [Account] = []
    var recentTransactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?

    private let analyticsService = AnalyticsService.shared
    private let accountService = AccountService.shared
    private let transactionService = TransactionService.shared

    var totalBalance: Double {
        summary?.currentBalanceDouble ?? 0
    }

    var iqScore: Int {
        guard let summary = summary else { return 0 }
        let income = summary.totalIncomeDouble
        guard income > 0 else { return 0 }
        let savingsRatio = (income - summary.totalExpenseDouble) / income
        return Int(savingsRatio * 100)
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let summaryTask = analyticsService.getSummary()
            async let accountsTask = accountService.getAccounts()
            async let transactionsTask = transactionService.getTransactions()

            let (fetchedSummary, fetchedAccounts, fetchedTransactions) = try await (summaryTask, accountsTask, transactionsTask)

            self.summary = fetchedSummary
            self.accounts = fetchedAccounts
            self.recentTransactions = Array(fetchedTransactions.prefix(5))
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load data"
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }
}