import Foundation

// MARK: - Category

enum CategoryType: String, Codable {
    case income
    case expense
}

struct Category: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let type: CategoryType
    let icon: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, userId, name, type, icon, createdAt
    }
}

struct CreateCategoryRequest: Encodable {
    let name: String
    let type: CategoryType
    let icon: String?
}

struct UpdateCategoryRequest: Encodable {
    let name: String?
    let type: CategoryType?
    let icon: String?
}