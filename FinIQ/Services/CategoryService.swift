import Foundation

actor CategoryService {
    static let shared = CategoryService()

    private let client = APIClient.shared

    func getCategories() async throws -> [Category] {
        try await client.request(endpoint: "/categories")
    }

    func createCategory(name: String, type: CategoryType, icon: String? = nil) async throws -> Category {
        let request = CreateCategoryRequest(name: name, type: type, icon: icon)
        return try await client.request(
            endpoint: "/categories",
            method: .post,
            body: request
        )
    }

    func updateCategory(id: String, name: String? = nil, type: CategoryType? = nil, icon: String? = nil) async throws -> Category {
        let request = UpdateCategoryRequest(name: name, type: type, icon: icon)
        return try await client.request(
            endpoint: "/categories/\(id)",
            method: .patch,
            body: request
        )
    }

    func deleteCategory(id: String) async throws {
        try await client.requestNoData(
            endpoint: "/categories/\(id)",
            method: .delete
        )
    }
}