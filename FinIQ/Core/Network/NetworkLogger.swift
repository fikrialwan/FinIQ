import Foundation

final class NetworkLogger {
    static let shared = NetworkLogger()

    private(set) var entries: [NetworkLogEntry] = []
    private let queue = DispatchQueue(label: "com.finiq.networklogger")

    struct NetworkLogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let method: String
        let url: String
        let statusCode: Int?
        let requestBody: Data?
        let responseBody: Data?
        let duration: TimeInterval?
        let error: String?

        var formattedTimestamp: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }

        var requestBodyString: String? {
            guard let data = requestBody else { return nil }
            return String(data: data, encoding: .utf8)
        }

        var responseBodyString: String? {
            guard let data = responseBody else { return nil }
            return String(data: data, encoding: .utf8)
        }
    }

    private init() {}

    func log(request: URLRequest, response: HTTPURLResponse?, data: Data?, duration: TimeInterval, error: Error?) {
        queue.async { [weak self] in
            guard let self = self else { return }

            let entry = NetworkLogEntry(
                timestamp: Date(),
                method: request.httpMethod ?? "?",
                url: request.url?.absoluteString ?? "?",
                statusCode: response?.statusCode,
                requestBody: request.httpBody,
                responseBody: data,
                duration: duration,
                error: error?.localizedDescription
            )

            self.entries.insert(entry, at: 0)

            // Keep last 100 entries
            if self.entries.count > 100 {
                self.entries = Array(self.entries.prefix(100))
            }

            // Print to console for debugging
            #if DEBUG
            print("🌐 \(entry.method) \(entry.url) - \(response?.statusCode ?? 0) (\(String(format: "%.2f", (duration ?? 0) * 1000))ms)")
            #endif
        }
    }

    func clear() {
        queue.async { [weak self] in
            self?.entries.removeAll()
        }
    }
}