import Foundation

// MARK: - Saving Goal

struct SavingGoal: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let targetAmount: String
    let currentAmount: String
    let targetDate: String?
    let percentageComplete: String?
    let remainingAmount: String?
    let daysRemaining: Int?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, name, targetAmount, currentAmount, targetDate
        case percentageComplete, remainingAmount, daysRemaining, createdAt
    }

    var targetAmountDouble: Double {
        Double(targetAmount) ?? 0
    }

    var currentAmountDouble: Double {
        Double(currentAmount) ?? 0
    }

    var percentageCompleteDouble: Double {
        Double(percentageComplete ?? "0") ?? 0
    }

    var remainingAmountDouble: Double {
        Double(remainingAmount ?? "0") ?? 0
    }
}

struct CreateGoalRequest: Encodable {
    let name: String
    let targetAmount: String
    let targetDate: String?
}

struct GoalDepositRequest: Encodable {
    let amount: String
    let fromAccountId: String
}

// MARK: - Goal Log

struct GoalLog: Codable, Identifiable {
    let id: String
    let goalId: String
    let amount: String
    let transactionId: String
    let createdAt: String?
}