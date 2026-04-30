import Foundation
import Security

enum KeychainError: Error {
    case duplicateItem
    case itemNotFound
    case unexpectedStatus(OSStatus)
    case invalidData
}

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.finiq.app"

    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let tokenExpiry = "tokenExpiry"
    }

    private init() {}

    // MARK: - Token Management

    func saveTokens(_ tokens: AuthTokens) throws {
        try save(key: Keys.accessToken, data: tokens.accessToken.data(using: .utf8)!)
        try save(key: Keys.refreshToken, data: tokens.refreshToken.data(using: .utf8)!)
        try save(key: Keys.tokenExpiry, data: tokens.expiresAt.data(using: .utf8)!)
    }

    func getAccessToken() -> String? {
        guard let data = load(key: Keys.accessToken) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func getRefreshToken() -> String? {
        guard let data = load(key: Keys.refreshToken) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func getTokenExpiry() -> String? {
        guard let data = load(key: Keys.tokenExpiry) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func clearTokens() {
        delete(key: Keys.accessToken)
        delete(key: Keys.refreshToken)
        delete(key: Keys.tokenExpiry)
    }

    var hasValidToken: Bool {
        getAccessToken() != nil
    }

    // MARK: - Private Keychain Operations

    private func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            try update(key: key, data: data)
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func update(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}