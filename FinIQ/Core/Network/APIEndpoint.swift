import Foundation

enum APIEndpoint {
    case register(email: String, password: String, currencyPref: String?)
    case login(email: String, password: String)
    case refresh(token: String)

    case getAccounts
    case createAccount(name: String, type: AccountType, balance: String?)
    case updateAccount(id: String, name: String?, type: AccountType?, balance: String?)
    case deleteAccount(id: String)

    case getCategories
    case createCategory(name: String, type: CategoryType, icon: String?)
    case updateCategory(id: String, name: String?, type: CategoryType?, icon: String?)
    case deleteCategory(id: String)

    case getTransactions
    case createTransaction(accountId: String, amount: String, type: TransactionType, categoryId: String?, note: String?, date: String?)
    case deleteTransaction(id: String)

    case createTransfer(fromAccountId: String, toAccountId: String, amount: String, note: String?, date: String?)

    case getGoals
    case createGoal(name: String, targetAmount: String, targetDate: String?)
    case depositToGoal(id: String, amount: String, fromAccountId: String)

    case getAnalyticsSummary
    case getSavingsProjection

    var path: String {
        switch self {
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .refresh: return "/auth/refresh"
        case .getAccounts, .createAccount: return "/accounts"
        case .updateAccount(let id, _, _, _), .deleteAccount(let id): return "/accounts/\(id)"
        case .getCategories, .createCategory: return "/categories"
        case .updateCategory(let id, _, _, _), .deleteCategory(let id): return "/categories/\(id)"
        case .getTransactions, .createTransaction: return "/transactions"
        case .deleteTransaction(let id): return "/transactions/\(id)"
        case .createTransfer: return "/transfers"
        case .getGoals, .createGoal: return "/goals"
        case .depositToGoal(let id, _, _): return "/goals/\(id)/deposit"
        case .getAnalyticsSummary: return "/analytics/summary"
        case .getSavingsProjection: return "/analytics/savings-projection"
        }
    }

    var method: String {
        switch self {
        case .register, .login, .refresh, .createAccount, .createCategory, .createTransaction, .createTransfer, .createGoal, .depositToGoal:
            return "POST"
        case .getAccounts, .getCategories, .getTransactions, .getGoals, .getAnalyticsSummary, .getSavingsProjection:
            return "GET"
        case .updateAccount, .updateCategory:
            return "PATCH"
        case .deleteAccount, .deleteCategory, .deleteTransaction:
            return "DELETE"
        }
    }

    var body: Encodable? {
        switch self {
        case .register(let email, let password, let currencyPref):
            return RegisterRequest(email: email, password: password, currencyPref: currencyPref)
        case .login(let email, let password):
            return LoginRequest(email: email, password: password)
        case .refresh(let token):
            return RefreshTokenRequest(token: token)
        case .createAccount(let name, let type, let balance):
            return CreateAccountRequest(name: name, type: type, balance: balance)
        case .updateAccount(_, let name, let type, let balance):
            return UpdateAccountRequest(name: name, type: type, balance: balance)
        case .createCategory(let name, let type, let icon):
            return CreateCategoryRequest(name: name, type: type, icon: icon)
        case .updateCategory(_, let name, let type, let icon):
            return UpdateCategoryRequest(name: name, type: type, icon: icon)
        case .createTransaction(let accountId, let amount, let type, let categoryId, let note, let date):
            return CreateTransactionRequest(accountId: accountId, amount: amount, type: type, categoryId: categoryId, note: note, date: date)
        case .createTransfer(let fromAccountId, let toAccountId, let amount, let note, let date):
            return TransferRequest(fromAccountId: fromAccountId, toAccountId: toAccountId, amount: amount, note: note, date: date)
        case .createGoal(let name, let targetAmount, let targetDate):
            return CreateGoalRequest(name: name, targetAmount: targetAmount, targetDate: targetDate)
        case .depositToGoal(_, let amount, let fromAccountId):
            return DepositRequest(amount: amount, fromAccountId: fromAccountId)
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .register, .login, .refresh:
            return false
        default:
            return true
        }
    }
}