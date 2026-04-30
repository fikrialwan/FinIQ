import Foundation

actor GoalService {
    static let shared = GoalService()

    private let client = APIClient.shared

    func getGoals() async throws -> [SavingGoal] {
        try await client.request(endpoint: "/goals")
    }

    func createGoal(name: String, targetAmount: String, targetDate: String? = nil) async throws -> SavingGoal {
        let request = CreateGoalRequest(name: name, targetAmount: targetAmount, targetDate: targetDate)
        return try await client.request(
            endpoint: "/goals",
            method: .post,
            body: request
        )
    }

    func depositToGoal(goalId: String, amount: String, fromAccountId: String) async throws -> SavingGoal {
        let request = GoalDepositRequest(amount: amount, fromAccountId: fromAccountId)
        return try await client.request(
            endpoint: "/goals/\(goalId)/deposit",
            method: .post,
            body: request
        )
    }
}