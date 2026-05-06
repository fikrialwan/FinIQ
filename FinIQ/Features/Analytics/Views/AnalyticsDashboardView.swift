import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @State private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .month

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    timeRangePicker

                    summaryCards

                    incomeExpenseChart

                    savingsProjectionSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .refreshable {
                await viewModel.loadAnalytics()
            }
            .task {
                await viewModel.loadAnalytics()
            }
        }
    }

    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Total Income",
                    value: formatCurrency(viewModel.totalIncome),
                    color: .green,
                    icon: "arrow.down.circle.fill"
                )

                SummaryCard(
                    title: "Total Expense",
                    value: formatCurrency(viewModel.totalExpense),
                    color: .red,
                    icon: "arrow.up.circle.fill"
                )
            }

            SummaryCard(
                title: "Net Savings",
                value: formatCurrency(viewModel.netSavings),
                color: viewModel.netSavings >= 0 ? .teal : .orange,
                icon: "banknote.circle.fill"
            )
        }
    }

    private var incomeExpenseChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Income vs Expenses")
                .font(.headline)

            Chart {
                ForEach(groupedTransactions, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(item.type == .income ? Color.green : Color.red)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var savingsProjectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Goals Progress")
                .font(.headline)

            if viewModel.savingsProjections.isEmpty {
                Text("No active savings goals")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.savingsProjections, id: \.goalName) { projection in
                    SavingsProjectionRow(projection: projection)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var groupedTransactions: [TransactionGroupItem] {
        let calendar = Calendar.current
        var items: [TransactionGroupItem] = []

        for transaction in viewModel.transactions.prefix(30) {
            items.append(TransactionGroupItem(
                date: transaction.date,
                amount: Double(transaction.amount) ?? 0,
                type: transaction.type
            ))
        }

        return items
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "Rp 0"
    }
}

struct TransactionGroupItem {
    let date: Date
    let amount: Double
    let type: TransactionType
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct SavingsProjectionRow: View {
    let projection: SavingsProjection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(projection.goalName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(projection.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(projection.status == .achieved ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .foregroundStyle(projection.status == .achieved ? .green : .orange)
                    .cornerRadius(4)
            }

            Text("Remaining: \(formatCurrency(projection.remainingAmount))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ amount: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        if let decimal = Decimal(string: amount) {
            return formatter.string(from: decimal as NSDecimalNumber) ?? amount
        }
        return amount
    }
}