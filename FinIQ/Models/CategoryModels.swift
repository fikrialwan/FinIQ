import Foundation

struct Category: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let type: CategoryType
    let icon: String?
}

enum CategoryType: String, Codable {
    case income
    case expense
}

struct CreateCategoryRequest: Codable {
    let name: String
    let type: CategoryType
    let icon: String?
}

struct UpdateCategoryRequest: Codable {
    let name: String?
    let type: CategoryType?
    let icon: String?
}