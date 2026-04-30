import Foundation
import SwiftUI

@MainActor
@Observable
final class GoalViewModel {
    var goals: [SavingGoal] = []
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    private let goalService = GoalService.shared
    private let accountService = AccountService.shared

    var totalSaved: Double {
        goals.reduce(0) { $0 + $1.currentAmountDouble }
    }

    var totalTarget: Double {
        goals.reduce(0) { $0 + $1.targetAmountDouble }
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let goalsTask = goalService.getGoals()
            async let accountsTask = accountService.getAccounts()

            let (fetchedGoals, fetchedAccounts) = try await (goalsTask, accountsTask)

            self.goals = fetchedGoals
            self.accounts = fetchedAccounts
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load goals"
        }

        isLoading = false
    }

    func createGoal(name: String, targetAmount: String, targetDate: String?) async -> Bool {
        do {
            let goal = try await goalService.createGoal(name: name, targetAmount: targetAmount, targetDate: targetDate)
            goals.append(goal)
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to create goal"
            return false
        }
    }

    func depositToGoal(goalId: String, amount: String, fromAccountId: String) async -> Bool {
        do {
            let updated = try await goalService.depositToGoal(goalId: goalId, amount: amount, fromAccountId: fromAccountId)
            if let index = goals.firstIndex(where: { $0.id == goalId }) {
                goals[index] = updated
            }
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to deposit to goal"
            return false
        }
    }

    func refresh() async {
        await loadData()
    }
}