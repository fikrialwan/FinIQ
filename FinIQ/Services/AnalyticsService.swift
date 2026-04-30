import Foundation

actor AnalyticsService {
    static let shared = AnalyticsService()

    private let client = APIClient.shared

    func getSummary() async throws -> AnalyticsSummary {
        try await client.request(endpoint: "/analytics/summary")
    }

    func getSavingsProjections() async throws -> [SavingsProjection] {
        try await client.request(endpoint: "/analytics/savings-projection")
    }
}