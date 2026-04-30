//
//  AnalyticsViewModel.swift
//  FinIQ
//
//  Analytics business logic
//

import Foundation

@MainActor
@Observable
final class AnalyticsViewModel {
    var summary: AnalyticsSummary?
    var projections: [SavingsProjection] = []
    var isLoading = false
    var errorMessage: String?

    private let analyticsService = AnalyticsService.shared

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let summaryTask = analyticsService.getSummary()
            async let projectionsTask = analyticsService.getSavingsProjections()

            let (fetchedSummary, fetchedProjections) = try await (summaryTask, projectionsTask)

            self.summary = fetchedSummary
            self.projections = fetchedProjections
        } catch let error as APIError {
            errorMessage = error.message
        } catch {
            errorMessage = "Failed to load analytics"
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }
}

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}