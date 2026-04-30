//
//  AnalyticsDashboardView.swift
//  FinIQ
//
//  Analytics dashboard with summary and insights
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @State private var viewModel = AnalyticsViewModel()
    @State private var selectedPeriod: TimePeriod = .month

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary Cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            SummaryCard(
                                title: "Total Income",
                                value: "Rp \(Int(viewModel.summary?.totalIncomeDouble ?? 0).formatted())",
                                icon: "arrow.down.circle.fill",
                                color: .green
                            )

                            SummaryCard(
                                title: "Total Expense",
                                value: "Rp \(Int(viewModel.summary?.totalExpenseDouble ?? 0).formatted())",
                                icon: "arrow.up.circle.fill",
                                color: .red
                            )

                            SummaryCard(
                                title: "Current Balance",
                                value: "Rp \(Int(viewModel.summary?.currentBalanceDouble ?? 0).formatted())",
                                icon: "banknote.fill",
                                color: .blue
                            )

                            SummaryCard(
                                title: "In Goals",
                                value: "Rp \(Int(viewModel.summary?.totalAllocatedToGoalsDouble ?? 0).formatted())",
                                icon: "target",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)

                        // Balance Chart
                        if let summary = viewModel.summary {
                            BalanceChartView(summary: summary)
                                .padding(.horizontal)
                        }

                        // Savings Projections
                        if !viewModel.projections.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Savings Goals")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(viewModel.projections, id: \.goalName) { projection in
                                    SavingsProjectionRow(projection: projection)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Analytics")
        .refreshable {
            await viewModel.loadData()
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct SummaryCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BalanceChartView: View {
    var summary: AnalyticsSummary

    private var balancePercentage: Double {
        guard summary.totalIncomeDouble > 0 else { return 0 }
        return min(1, summary.currentBalanceDouble / summary.totalIncomeDouble)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Balance Overview")
                .font(.headline)

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 24)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * balancePercentage, height: 24)
                    }
                }
                .frame(height: 24)

                HStack {
                    Text("Expense: Rp \(Int(summary.totalExpenseDouble).formatted())")
                        .font(.caption)
                        .foregroundStyle(.red)

                    Spacer()

                    Text("Balance: Rp \(Int(summary.currentBalanceDouble).formatted())")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SavingsProjectionRow: View {
    var projection: SavingsProjection

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(projection.goalName)
                    .font(.headline)

                Text("Remaining: Rp \(Int(projection.remainingAmountDouble).formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(projection.status)
                .font(.caption.bold())
                .foregroundStyle(projection.isAchieved ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(projection.isAchieved ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        AnalyticsDashboardView()
    }
}