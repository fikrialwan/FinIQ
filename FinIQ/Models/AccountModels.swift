import Foundation

enum AccountType: String, Codable, CaseIterable {
    case cash
    case bank
    case creditCard = "credit_card"
    case digitalWallet = "digital_wallet"
    case investment

    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .bank: return "Bank"
        case .creditCard: return "Credit Card"
        case .digitalWallet: return "Digital Wallet"
        case .investment: return "Investment"
        }
    }
}

struct Account: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let type: AccountType
    let balance: String
    let safeToSpend: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, name, type, balance
        case safeToSpend = "safeToSpend"
    }
}

struct CreateAccountRequest: Codable {
    let name: String
    let type: AccountType
    let balance: String?

    enum CodingKeys: String, CodingKey {
        case name, type, balance
    }
}

struct UpdateAccountRequest: Codable {
    let name: String?
    let type: AccountType?
    let balance: String?
}