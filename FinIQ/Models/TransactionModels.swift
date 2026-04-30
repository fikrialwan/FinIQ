import Foundation

// MARK: - Transaction

enum TransactionType: String, Codable {
    case income
    case expense
    case transfer
}

struct Transaction: Codable, Identifiable {
    let id: String
    let accountId: String
    let categoryId: String?
    let amount: String
    let type: TransactionType
    let note: String?
    let date: String
    let account: Account?
    let category: Category?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, accountId, categoryId, amount, type, note, date, account, category, createdAt
    }

    init(id: String, accountId: String, categoryId: String?, amount: String, type: TransactionType, note: String?, date: String, account: Account?, category: Category?, createdAt: String?) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.type = type
        self.note = note
        self.date = date
        self.account = account
        self.category = category
        self.createdAt = createdAt
    }

    var amountDouble: Double {
        Double(amount) ?? 0
    }
}

struct CreateTransactionRequest: Encodable {
    let accountId: String
    let amount: String
    let type: TransactionType
    let categoryId: String?
    let note: String?
    let date: String?
}

// MARK: - Transfer

struct Transfer: Codable, Identifiable {
    let id: String
    let fromAccountId: String
    let toAccountId: String
    let transactionId: String
}

struct CreateTransferRequest: Encodable {
    let fromAccountId: String
    let toAccountId: String
    let amount: String
    let note: String?
    let date: String?
}

struct TransferResponse: Codable {
    let id: String
    let fromAccountId: String
    let toAccountId: String
    let transactionId: String
}