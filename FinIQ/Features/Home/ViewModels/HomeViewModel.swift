import Foundation

@MainActor
@Observable
final class HomeViewModel {
    var accounts: [Account] = []
    var goals: [Goal] = []
    var analyticsSummary: AnalyticsSummary?
    var isLoading = false
    var errorMessage: String?
    var isOffline = false

    private let apiClient = APIClient.shared
    private let cache = CacheManager.shared

    var totalNetWorth: Decimal {
        accounts.reduce(Decimal(string: "0") ?? 0) { result, account in
            result + (Decimal(string: account.balance) ?? 0)
        }
    }

    var totalAllocatedToGoals: Decimal {
        goals.reduce(Decimal(string: "0") ?? 0) { result, goal in
            result + (Decimal(string: goal.currentAmount) ?? 0)
        }
    }

    var safeToSpend: Decimal {
        totalNetWorth - totalAllocatedToGoals
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        // Load from cache first for instant display
        accounts = await cache.getCachedAccounts()
        goals = await cache.getCachedGoals()
        if let cached = await cache.getCachedAnalyticsSummary() {
            analyticsSummary = cached
        }

        // Then fetch from API
        do {
            async let accountsTask: [Account] = apiClient.request(.getAccounts)
            async let goalsTask: [Goal] = apiClient.request(.getGoals)
            async let summaryTask: AnalyticsSummary = apiClient.request(.getAnalyticsSummary)

            let (fetchedAccounts, fetchedGoals, fetchedSummary) = try await (accountsTask, goalsTask, summaryTask)

            accounts = fetchedAccounts
            goals = fetchedGoals
            analyticsSummary = fetchedSummary
            isOffline = false

            // Update cache
            await cache.cacheAccounts(fetchedAccounts)
            await cache.cacheGoals(fetchedGoals)
            await cache.cacheAnalyticsSummary(fetchedSummary)
        } catch {
            if accounts.isEmpty && goals.isEmpty {
                errorMessage = "Failed to load data. Please check your connection."
            } else {
                isOffline = true
            }
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }
}