import Foundation

struct AnalyticsSummary: Codable {
    let totalIncome: String
    let totalExpense: String
    let currentBalance: String
    let totalAllocatedToGoals: String
}

struct SavingsProjection: Codable {
    let goalName: String
    let remainingAmount: String
    let status: ProjectionStatus
}

enum ProjectionStatus: String, Codable {
    case achieved = "Achieved"
    case inProgress = "In Progress"
}