import Foundation

struct Goal: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let targetAmount: String
    let currentAmount: String
    let targetDate: Date?
    let percentageComplete: String
    let remainingAmount: String
    let daysRemaining: Int?
    let isCompleted: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, userId, name, targetAmount, currentAmount, targetDate
        case percentageComplete, remainingAmount, daysRemaining
        case isCompleted, createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        targetAmount = try container.decode(String.self, forKey: .targetAmount)
        currentAmount = try container.decode(String.self, forKey: .currentAmount)
        targetDate = try container.decodeIfPresent(Date.self, forKey: .targetDate)
        percentageComplete = try container.decodeIfPresent(String.self, forKey: .percentageComplete) ?? "0"
        remainingAmount = try container.decodeIfPresent(String.self, forKey: .remainingAmount) ?? "0"
        daysRemaining = try container.decodeIfPresent(Int.self, forKey: .daysRemaining)

        // Handle string "true"/"false" from API
        let isCompletedString = try container.decodeIfPresent(String.self, forKey: .isCompleted) ?? "false"
        isCompleted = isCompletedString.lowercased() == "true"

        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(targetAmount, forKey: .targetAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encodeIfPresent(targetDate, forKey: .targetDate)
        try container.encode(percentageComplete, forKey: .percentageComplete)
        try container.encode(remainingAmount, forKey: .remainingAmount)
        try container.encodeIfPresent(daysRemaining, forKey: .daysRemaining)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }

    init(
        id: String,
        userId: String,
        name: String,
        targetAmount: String,
        currentAmount: String,
        targetDate: Date?,
        percentageComplete: String = "0",
        remainingAmount: String = "0",
        daysRemaining: Int? = nil,
        isCompleted: Bool = false,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.percentageComplete = percentageComplete
        self.remainingAmount = remainingAmount
        self.daysRemaining = daysRemaining
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

struct CreateGoalRequest: Codable {
    let name: String
    let targetAmount: String
    let targetDate: String?
}

struct DepositRequest: Codable {
    let amount: String
    let fromAccountId: String
}