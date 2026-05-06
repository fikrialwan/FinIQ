import Foundation

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
    let date: Date
    let account: TransactionAccount?
    let category: TransactionCategory?
}

struct TransactionAccount: Codable {
    let id: String
    let name: String
    let type: String
}

struct TransactionCategory: Codable {
    let id: String
    let name: String
    let icon: String?
}

struct CreateTransactionRequest: Codable {
    let accountId: String
    let amount: String
    let type: TransactionType
    let categoryId: String?
    let note: String?
    let date: String?
}

struct TransferRequest: Codable {
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