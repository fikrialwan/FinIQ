import Foundation

@MainActor
@Observable
final class AnalyticsViewModel {
    var summary: AnalyticsSummary?
    var savingsProjections: [SavingsProjection] = []
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?

    private let apiClient = APIClient.shared

    var incomeTransactions: [Transaction] {
        transactions.filter { $0.type == .income }
    }

    var expenseTransactions: [Transaction] {
        transactions.filter { $0.type == .expense }
    }

    var totalIncome: Decimal {
        incomeTransactions.reduce(Decimal(string: "0") ?? 0) { result, transaction in
            result + (Decimal(string: transaction.amount) ?? 0)
        }
    }

    var totalExpense: Decimal {
        expenseTransactions.reduce(Decimal(string: "0") ?? 0) { result, transaction in
            result + (Decimal(string: transaction.amount) ?? 0)
        }
    }

    var netSavings: Decimal {
        totalIncome - totalExpense
    }

    func loadAnalytics() async {
        isLoading = true
        errorMessage = nil

        do {
            async let summaryTask: AnalyticsSummary = apiClient.request(.getAnalyticsSummary)
            async let projectionsTask: [SavingsProjection] = apiClient.request(.getSavingsProjection)
            async let transactionsTask: [Transaction] = apiClient.request(.getTransactions)

            let (fetchedSummary, fetchedProjections, fetchedTransactions) = try await (summaryTask, projectionsTask, transactionsTask)

            summary = fetchedSummary
            savingsProjections = fetchedProjections
            transactions = fetchedTransactions
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load analytics"
        }

        isLoading = false
    }
}