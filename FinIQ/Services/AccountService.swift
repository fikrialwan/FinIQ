import Foundation

actor AccountService {
    static let shared = AccountService()

    private let client = APIClient.shared

    func getAccounts() async throws -> [Account] {
        try await client.request(endpoint: "/accounts")
    }

    func createAccount(name: String, type: AccountType, balance: String? = nil) async throws -> Account {
        let request = CreateAccountRequest(name: name, type: type, balance: balance)
        return try await client.request(
            endpoint: "/accounts",
            method: .post,
            body: request
        )
    }

    func updateAccount(id: String, name: String? = nil, type: AccountType? = nil, balance: String? = nil) async throws -> Account {
        let request = UpdateAccountRequest(name: name, type: type, balance: balance)
        return try await client.request(
            endpoint: "/accounts/\(id)",
            method: .patch,
            body: request
        )
    }

    func deleteAccount(id: String) async throws {
        try await client.requestNoData(
            endpoint: "/accounts/\(id)",
            method: .delete
        )
    }
}