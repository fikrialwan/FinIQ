import Foundation

// MARK: - Account

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

    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .bank: return "building.columns"
        case .creditCard: return "creditcard"
        case .digitalWallet: return "wallet.pass"
        case .investment: return "chart.line.uptrend.xyaxis"
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
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, name, type, balance, safeToSpend, createdAt
    }

    init(id: String, userId: String, name: String, type: AccountType, balance: String, safeToSpend: String? = nil, createdAt: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.balance = balance
        self.safeToSpend = safeToSpend
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(AccountType.self, forKey: .type)
        balance = try container.decode(String.self, forKey: .balance)
        safeToSpend = try container.decodeIfPresent(String.self, forKey: .safeToSpend)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }

    var balanceDouble: Double {
        Double(balance) ?? 0
    }

    var safeToSpendDouble: Double {
        Double(safeToSpend ?? balance) ?? 0
    }
}

struct CreateAccountRequest: Encodable {
    let name: String
    let type: AccountType
    let balance: String?
}

struct UpdateAccountRequest: Encodable {
    let name: String?
    let type: AccountType?
    let balance: String?
}