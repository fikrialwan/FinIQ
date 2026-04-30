//
//  TransactionListView.swift
//  FinIQ
//
//  Transaction list screen
//

import SwiftUI

struct TransactionListView: View {
    @State private var viewModel = ActivityViewModel()
    @State private var showAddTransaction = false
    @State private var selectedFilter: TransactionType?

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.transactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "list.bullet",
                    description: Text("Your transactions will appear here")
                )
            } else {
                List {
                    ForEach(groupedTransactions, id: \.date) { group in
                        Section(header: Text(group.dateLabel)) {
                            ForEach(group.transactions) { transaction in
                                NavigationLink(destination: TransactionDetailView(transaction: transaction, viewModel: viewModel)) {
                                    TransactionRowView(transaction: transaction)
                                }
                            }
                            .onDelete { indexSet in
                                Task {
                                    for index in indexSet {
                                        let tx = group.transactions[index]
                                        await viewModel.deleteTransaction(id: tx.id)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Transactions")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddTransaction = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadData()
        }
    }

    private var groupedTransactions: [TransactionGroup] {
        let filtered = selectedFilter == nil
            ? viewModel.transactions
            : viewModel.transactions.filter { $0.type == selectedFilter }

        let grouped = Dictionary(grouping: filtered) { tx in
            Calendar.current.startOfDay(for: ISO8601DateFormatter().date(from: tx.date) ?? Date())
        }

        return grouped.map { (date, txs) in
            TransactionGroup(date: date, transactions: txs.sorted { $0.date > $1.date })
        }.sorted { $0.date > $1.date }
    }
}

struct TransactionGroup: Identifiable {
    let date: Date
    let transactions: [Transaction]

    var id: Date { date }

    var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

struct TransactionRowView: View {
    var transaction: Transaction

    private var icon: String {
        switch transaction.type {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? transaction.type.rawValue.capitalized)
                    .font(.headline)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedAmount)
                    .font(.headline)
                    .foregroundStyle(transaction.type == .expense ? .red : .green)
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedAmount: String {
        let amount = transaction.amountDouble
        let prefix = transaction.type == .expense ? "-" : "+"
        return "\(prefix)Rp \(Int(amount).formatted())"
    }

    private var formattedTime: String {
        guard let date = ISO8601DateFormatter().date(from: transaction.date) else {
            return ""
        }
        return date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    NavigationStack {
        TransactionListView()
    }
}