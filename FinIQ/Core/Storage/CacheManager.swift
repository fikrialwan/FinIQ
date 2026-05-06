import Foundation
import SwiftData

@MainActor
final class CacheManager {
    static let shared = CacheManager()

    private var modelContainer: ModelContainer?

    private init() {
        setupContainer()
    }

    private func setupContainer() {
        do {
            let schema = Schema([
                CachedAccount.self,
                CachedTransaction.self,
                CachedGoal.self,
                CachedAnalyticsSummary.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("CacheManager: Failed to setup SwiftData container: \(error)")
        }
    }

    func cacheAccounts(_ accounts: [Account]) async {
        guard let container = modelContainer else { return }

        let context = container.mainContext
        for account in accounts {
            let cached = CachedAccount(from: account)
            context.insert(cached)
        }
        try? context.save()
    }

    func getCachedAccounts() async -> [Account] {
        guard let container = modelContainer else { return [] }

        let context = container.mainContext
        let descriptor = FetchDescriptor<CachedAccount>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )

        guard let cached = try? context.fetch(descriptor) else { return [] }
        return cached.map { $0.toAccount() }
    }

    func cacheTransactions(_ transactions: [Transaction]) async {
        guard let container = modelContainer else { return }

        let context = container.mainContext
        for transaction in transactions {
            let cached = CachedTransaction(from: transaction)
            context.insert(cached)
        }
        try? context.save()
    }

    func getCachedTransactions() async -> [Transaction] {
        guard let container = modelContainer else { return [] }

        let context = container.mainContext
        let descriptor = FetchDescriptor<CachedTransaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let cached = try? context.fetch(descriptor) else { return [] }
        return cached.map { $0.toTransaction() }
    }

    func cacheGoals(_ goals: [Goal]) async {
        guard let container = modelContainer else { return }

        let context = container.mainContext
        for goal in goals {
            let cached = CachedGoal(from: goal)
            context.insert(cached)
        }
        try? context.save()
    }

    func getCachedGoals() async -> [Goal] {
        guard let container = modelContainer else { return [] }

        let context = container.mainContext
        let descriptor = FetchDescriptor<CachedGoal>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )

        guard let cached = try? context.fetch(descriptor) else { return [] }
        return cached.map { $0.toGoal() }
    }

    func cacheAnalyticsSummary(_ summary: AnalyticsSummary) async {
        guard let container = modelContainer else { return }

        let context = container.mainContext
        let cached = CachedAnalyticsSummary(from: summary)
        context.insert(cached)
        try? context.save()
    }

    func getCachedAnalyticsSummary() async -> AnalyticsSummary? {
        guard let container = modelContainer else { return nil }

        let context = container.mainContext
        let descriptor = FetchDescriptor<CachedAnalyticsSummary>()

        guard let cached = try? context.fetch(descriptor).first else { return nil }
        return cached.toSummary()
    }

    func clearAllCache() async {
        guard let container = modelContainer else { return }

        let context = container.mainContext
        try? context.delete(model: CachedAccount.self)
        try? context.delete(model: CachedTransaction.self)
        try? context.delete(model: CachedGoal.self)
        try? context.delete(model: CachedAnalyticsSummary.self)
        try? context.save()
    }
}

@Model
final class CachedAccount {
    @Attribute(.unique) var id: String
    var userId: String
    var name: String
    var type: String
    var balance: String
    var safeToSpend: String?
    var cachedAt: Date

    init(from account: Account) {
        self.id = account.id
        self.userId = account.userId
        self.name = account.name
        self.type = account.type.rawValue
        self.balance = account.balance
        self.safeToSpend = account.safeToSpend
        self.cachedAt = Date()
    }

    func toAccount() -> Account {
        Account(
            id: id,
            userId: userId,
            name: name,
            type: AccountType(rawValue: type) ?? .cash,
            balance: balance,
            safeToSpend: safeToSpend
        )
    }
}

@Model
final class CachedTransaction {
    @Attribute(.unique) var id: String
    var accountId: String
    var categoryId: String?
    var amount: String
    var type: String
    var note: String?
    var date: Date
    var cachedAt: Date

    init(from transaction: Transaction) {
        self.id = transaction.id
        self.accountId = transaction.accountId
        self.categoryId = transaction.categoryId
        self.amount = transaction.amount
        self.type = transaction.type.rawValue
        self.note = transaction.note
        self.date = transaction.date
        self.cachedAt = Date()
    }

    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            type: TransactionType(rawValue: type) ?? .expense,
            note: note,
            date: date,
            account: nil,
            category: nil
        )
    }
}

@Model
final class CachedGoal {
    @Attribute(.unique) var id: String
    var userId: String
    var name: String
    var targetAmount: String
    var currentAmount: String
    var targetDate: Date?
    var percentageComplete: String
    var remainingAmount: String
    var daysRemaining: Int?
    var cachedAt: Date

    init(from goal: Goal) {
        self.id = goal.id
        self.userId = goal.userId
        self.name = goal.name
        self.targetAmount = goal.targetAmount
        self.currentAmount = goal.currentAmount
        self.targetDate = goal.targetDate
        self.percentageComplete = goal.percentageComplete
        self.remainingAmount = goal.remainingAmount
        self.daysRemaining = goal.daysRemaining
        self.cachedAt = Date()
    }

    func toGoal() -> Goal {
        Goal(
            id: id,
            userId: userId,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            targetDate: targetDate,
            percentageComplete: percentageComplete,
            remainingAmount: remainingAmount,
            daysRemaining: daysRemaining
        )
    }
}

@Model
final class CachedAnalyticsSummary {
    @Attribute(.unique) var id: String
    var totalIncome: String
    var totalExpense: String
    var currentBalance: String
    var totalAllocatedToGoals: String
    var cachedAt: Date

    init(from summary: AnalyticsSummary) {
        self.id = "singleton"
        self.totalIncome = summary.totalIncome
        self.totalExpense = summary.totalExpense
        self.currentBalance = summary.currentBalance
        self.totalAllocatedToGoals = summary.totalAllocatedToGoals
        self.cachedAt = Date()
    }

    func toSummary() -> AnalyticsSummary {
        AnalyticsSummary(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            currentBalance: currentBalance,
            totalAllocatedToGoals: totalAllocatedToGoals
        )
    }
}