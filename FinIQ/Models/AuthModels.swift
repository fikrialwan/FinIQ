import Foundation

// MARK: - Auth Models

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let currencyPref: String?

    enum CodingKeys: String, CodingKey {
        case email, password
        case currencyPref = "currency_pref"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let token: String
}

// MARK: - Error Codes

enum AuthErrorCode: Int {
    case userExists = 201
    case invalidCredentials = 202
    case invalidRefreshToken = 203
    case unauthorized = 103
}