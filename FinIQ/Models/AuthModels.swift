import Foundation

// MARK: - API Response Wrapper

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let errorCode: Int?
    let message: String
    let data: T?
}

// MARK: - Auth Models

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let currencyPref: String?
}

struct RefreshRequest: Encodable {
    let token: String
}

// MARK: - Error Codes

enum APIErrorCode: Int, Decodable {
    case INTERNAL_SERVER_ERROR = 100
    case NOT_FOUND = 101
    case BAD_REQUEST = 102
    case UNAUTHORIZED = 103
    case USER_EXISTS = 201
    case INVALID_CREDENTIALS = 202
    case INVALID_REFRESH_TOKEN = 203
    case ACCOUNT_NOT_FOUND = 300
    case ACCESS_DENIED = 301
    case CATEGORY_NOT_FOUND = 400
    case TRANSACTION_NOT_FOUND = 500
    case LOG_FAILED = 501
    case SAME_ACCOUNT = 600
    case TRANSFER_ACCOUNT_NOT_FOUND = 601

    var message: String {
        switch self {
        case .INTERNAL_SERVER_ERROR: return "Internal server error"
        case .NOT_FOUND: return "Resource not found"
        case .BAD_REQUEST: return "Validation failed"
        case .UNAUTHORIZED: return "Unauthorized"
        case .USER_EXISTS: return "Email already registered"
        case .INVALID_CREDENTIALS: return "Wrong email or password"
        case .INVALID_REFRESH_TOKEN: return "Invalid refresh token"
        case .ACCOUNT_NOT_FOUND: return "Account not found"
        case .ACCESS_DENIED: return "Access denied"
        case .CATEGORY_NOT_FOUND: return "Category not found"
        case .TRANSACTION_NOT_FOUND: return "Transaction not found"
        case .LOG_FAILED: return "Failed to log transaction"
        case .SAME_ACCOUNT: return "Source and destination identical"
        case .TRANSFER_ACCOUNT_NOT_FOUND: return "Transfer account not found"
        }
    }
}

// MARK: - API Error

struct APIError: Error, LocalizedError {
    let code: APIErrorCode
    let message: String

    var errorDescription: String? { message }

    init(code: APIErrorCode, message: String? = nil) {
        self.code = code
        self.message = message ?? code.message
    }
}