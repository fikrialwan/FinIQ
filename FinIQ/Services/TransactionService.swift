import Foundation

actor TransactionService {
    static let shared = TransactionService()

    private let client = APIClient.shared

    func getTransactions() async throws -> [Transaction] {
        try await client.request(endpoint: "/transactions")
    }

    func createTransaction(
        accountId: String,
        amount: String,
        type: TransactionType,
        categoryId: String? = nil,
        note: String? = nil,
        date: String? = nil
    ) async throws -> Transaction {
        let request = CreateTransactionRequest(
            accountId: accountId,
            amount: amount,
            type: type,
            categoryId: categoryId,
            note: note,
            date: date
        )
        return try await client.request(
            endpoint: "/transactions",
            method: .post,
            body: request
        )
    }

    func deleteTransaction(id: String) async throws {
        try await client.requestNoData(
            endpoint: "/transactions/\(id)",
            method: .delete
        )
    }

    func transfer(
        fromAccountId: String,
        toAccountId: String,
        amount: String,
        note: String? = nil,
        date: String? = nil
    ) async throws -> TransferResponse {
        let request = CreateTransferRequest(
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            amount: amount,
            note: note,
            date: date
        )
        return try await client.request(
            endpoint: "/transfers",
            method: .post,
            body: request
        )
    }
}