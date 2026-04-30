import Foundation

// MARK: - Analytics Summary

struct AnalyticsSummary: Codable {
    let totalIncome: String
    let totalExpense: String
    let currentBalance: String
    let totalAllocatedToGoals: String

    enum CodingKeys: String, CodingKey {
        case totalIncome, totalExpense, currentBalance, totalAllocatedToGoals
    }

    var totalIncomeDouble: Double { Double(totalIncome) ?? 0 }
    var totalExpenseDouble: Double { Double(totalExpense) ?? 0 }
    var currentBalanceDouble: Double { Double(currentBalance) ?? 0 }
    var totalAllocatedToGoalsDouble: Double { Double(totalAllocatedToGoals) ?? 0 }
}

// MARK: - Savings Projection

struct SavingsProjection: Codable {
    let goalName: String
    let remainingAmount: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case goalName, remainingAmount, status
    }

    var isAchieved: Bool { status == "Achieved" }
    var remainingAmountDouble: Double { Double(remainingAmount) ?? 0 }
}