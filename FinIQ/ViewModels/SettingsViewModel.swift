import Foundation
import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    var categories: [Category] = []
    var isLoading = false
    var errorMessage: String?

    private let categoryService = CategoryService.shared

    func loadCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            categories = try await categoryService.getCategories()
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load categories"
        }

        isLoading = false
    }

    func createCategory(name: String, type: CategoryType, icon: String?) async -> Bool {
        do {
            let category = try await categoryService.createCategory(name: name, type: type, icon: icon)
            categories.append(category)
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to create category"
            return false
        }
    }

    func updateCategory(id: String, name: String?, type: CategoryType?, icon: String?) async -> Bool {
        do {
            let updated = try await categoryService.updateCategory(id: id, name: name, type: type, icon: icon)
            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index] = updated
            }
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to update category"
            return false
        }
    }

    func deleteCategory(id: String) async -> Bool {
        do {
            try await categoryService.deleteCategory(id: id)
            categories.removeAll { $0.id == id }
            return true
        } catch let error as APIError {
            errorMessage = error.message
            return false
        } catch {
            errorMessage = "Failed to delete category"
            return false
        }
    }

    func refresh() async {
        await loadCategories()
    }
}