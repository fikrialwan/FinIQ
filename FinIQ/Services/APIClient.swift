import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(APIError)
    case unauthorized
    case unknown
}

actor APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<Void, Error>] = []

    init(baseURL: String = Config.baseURL) {
        self.baseURL = baseURL
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Public API

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            if let token = await KeychainManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        if httpResponse.statusCode == 401 && requiresAuth {
            try await refreshToken()
            return try await self.request(endpoint: endpoint, method: method, body: body, requiresAuth: true)
        }

        let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)

        if apiResponse.success, let responseData = apiResponse.data {
            return responseData
        } else {
            let errorCode = APIErrorCode(rawValue: apiResponse.errorCode ?? 100) ?? .INTERNAL_SERVER_ERROR
            throw APIError(code: errorCode, message: apiResponse.message)
        }
    }

    func requestNoData(
        endpoint: String,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            if let token = KeychainManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        if httpResponse.statusCode == 401 && requiresAuth {
            try await refreshToken()
            try await self.requestNoData(endpoint: endpoint, method: method, body: body, requiresAuth: true)
            return
        }

        let apiResponse = try decoder.decode(APIResponse<String?>.self, from: data)

        if !apiResponse.success {
            let errorCode = APIErrorCode(rawValue: apiResponse.errorCode ?? 100) ?? .INTERNAL_SERVER_ERROR
            throw APIError(code: errorCode, message: apiResponse.message)
        }
    }

    // MARK: - Token Refresh

    private func refreshToken() async throws {
        if isRefreshing {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                refreshContinuations.append(continuation)
            }
            return
        }

        isRefreshing = true

        defer {
            isRefreshing = false
            let continuations = refreshContinuations
            refreshContinuations = []
            continuations.forEach { $0.resume() }
        }

        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            KeychainManager.shared.clearTokens()
            throw APIError(code: .INVALID_REFRESH_TOKEN)
        }

        let url = try buildURL(endpoint: "/auth/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(RefreshRequest(token: refreshToken))

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        if httpResponse.statusCode == 401 {
            KeychainManager.shared.clearTokens()
            throw APIError(code: .INVALID_REFRESH_TOKEN)
        }

        let apiResponse = try decoder.decode(APIResponse<AuthTokens>.self, from: data)

        guard apiResponse.success, let tokens = apiResponse.data else {
            KeychainManager.shared.clearTokens()
            throw APIError(code: .INVALID_REFRESH_TOKEN)
        }

        try KeychainManager.shared.saveTokens(tokens)
    }

    // MARK: - Helpers

    private func buildURL(endpoint: String) throws -> URL {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        return url
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
