import Foundation

final class APIClient: NSObject {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<Void, Error>] = []
    private let logger = NetworkLogger.shared

    private override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
            }
            return date
        }
        self.encoder = JSONEncoder()

        super.init()
    }

    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(for: endpoint)
        let startTime = Date()

        do {
            let (data, response) = try await session.data(for: request)
            let duration = Date().timeIntervalSince(startTime)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }

            // Log the request
            logger.log(
                request: request,
                response: httpResponse,
                data: data,
                duration: duration,
                error: nil
            )

            if httpResponse.statusCode == 401 && endpoint.requiresAuth {
                try await refreshAndRetry(endpoint: endpoint)
                return try await self.request(endpoint)
            }

            return try handleResponse(data: data, statusCode: httpResponse.statusCode)
        } catch let error as APIClientError {
            let duration = Date().timeIntervalSince(startTime)
            logger.log(request: request, response: nil, data: nil, duration: duration, error: error)
            throw error
        } catch let error as URLError {
            let duration = Date().timeIntervalSince(startTime)
            logger.log(request: request, response: nil, data: nil, duration: duration, error: error)
            throw APIClientError.networkError(error)
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            logger.log(request: request, response: nil, data: nil, duration: duration, error: error)
            throw APIClientError.networkError(error)
        }
    }

    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: Config.baseURL + endpoint.path) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.requiresAuth, let token = KeychainManager.shared.getToken(for: Config.accessTokenKey) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    private func handleResponse<T: Codable>(data: Data, statusCode: Int) throws -> T {
        if statusCode < 200 || statusCode >= 300 {
            if let errorResponse = try? decoder.decode(APIResponse<EmptyResponse>.self, from: data) {
                throw APIClientError.serverError(
                    code: errorResponse.errorCode ?? 100,
                    message: errorResponse.message
                )
            }
            throw APIClientError.httpError(statusCode: statusCode, message: "Request failed")
        }

        let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)

        if apiResponse.success, let responseData = apiResponse.data {
            return responseData
        } else {
            throw APIClientError.serverError(
                code: apiResponse.errorCode ?? 100,
                message: apiResponse.message
            )
        }
    }

    private func refreshAndRetry(endpoint: APIEndpoint) async throws {
        guard !isRefreshing else {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                refreshContinuations.append(continuation)
            }
            return
        }

        isRefreshing = true
        defer {
            isRefreshing = false
            refreshContinuations.forEach { $0.resume() }
            refreshContinuations.removeAll()
        }

        do {
            let newTokens: AuthTokens = try await request(.refresh(token: KeychainManager.shared.getToken(for: Config.refreshTokenKey) ?? ""))
            try KeychainManager.shared.saveToken(newTokens.accessToken, for: Config.accessTokenKey)
            try KeychainManager.shared.saveToken(newTokens.refreshToken, for: Config.refreshTokenKey)
            try KeychainManager.shared.saveToken(newTokens.expiresAt, for: Config.tokenExpiryKey)
        } catch {
            KeychainManager.shared.clearTokens()
            throw APIClientError.unauthorized
        }
    }
}

extension APIClient: URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // SSL Pinning: Validate certificate chain
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)

        if isValid {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}