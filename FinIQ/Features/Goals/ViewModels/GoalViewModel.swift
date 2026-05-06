import Foundation

@MainActor
@Observable
final class GoalViewModel {
    var goals: [Goal] = []
    var accounts: [Account] = []
    var isLoading = false
    var errorMessage: String?

    var selectedGoal: Goal?
    var showAddGoal = false

    // Form fields
    var name = ""
    var targetAmount = ""
    var targetDate = Date()
    var hasTargetDate = false

    // Deposit fields
    var depositAmount = ""
    var depositAccountId: String?
    var showDepositSheet = false

    private let apiClient = APIClient.shared

    func loadGoals() async {
        isLoading = true
        errorMessage = nil

        do {
            async let goalsTask: [Goal] = apiClient.request(.getGoals)
            async let accountsTask: [Account] = apiClient.request(.getAccounts)

            let (fetchedGoals, fetchedAccounts) = try await (goalsTask, accountsTask)

            goals = fetchedGoals
            accounts = fetchedAccounts
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load goals"
        }

        isLoading = false
    }

    func createGoal() async -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Goal name is required"
            return false
        }

        guard !targetAmount.isEmpty else {
            errorMessage = "Target amount is required"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let dateFormatter = ISO8601DateFormatter()
            let targetDateString = hasTargetDate ? dateFormatter.string(from: targetDate) : nil

            let newGoal: Goal = try await apiClient.request(
                .createGoal(name: name, targetAmount: targetAmount, targetDate: targetDateString)
            )

            goals.append(newGoal)
            resetForm()
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to create goal"
        }

        isLoading = false
        return false
    }

    func depositToGoal() async -> Bool {
        guard let goal = selectedGoal else { return false }
        guard let accountId = depositAccountId, !depositAmount.isEmpty else {
            errorMessage = "Please select an account and enter an amount"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let updatedGoal: Goal = try await apiClient.request(
                .depositToGoal(id: goal.id, amount: depositAmount, fromAccountId: accountId)
            )

            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = updatedGoal
            }

            resetDepositForm()
            isLoading = false
            return true
        } catch let error as APIClientError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to deposit to goal"
        }

        isLoading = false
        return false
    }

    func startDeposit(for goal: Goal) {
        selectedGoal = goal
        depositAmount = ""
        depositAccountId = nil
        showDepositSheet = true
    }

    func resetForm() {
        name = ""
        targetAmount = ""
        targetDate = Date()
        hasTargetDate = false
        selectedGoal = nil
        showAddGoal = false
    }

    func resetDepositForm() {
        depositAmount = ""
        depositAccountId = nil
        showDepositSheet = false
        selectedGoal = nil
    }
}