//
//  TransactionDetailView.swift
//  FinIQ
//
//  Transaction detail screen
//

import SwiftUI

struct TransactionDetailView: View {
    var transaction: Transaction
    @Bindable var viewModel: ActivityViewModel
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss

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
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundColor(iconColor)
                        .frame(width: 80, height: 80)
                        .background(iconColor.opacity(0.1))
                        .clipShape(Circle())

                    Text(formattedAmount)
                        .font(.largeTitle.bold())
                        .foregroundStyle(transaction.type == .expense ? .red : .green)

                    Text(transaction.type.rawValue.uppercased())
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

            Section("Details") {
                LabeledContent("Category") {
                    HStack {
                        if let icon = transaction.category?.icon {
                            Image(systemName: icon)
                        }
                        Text(transaction.category?.name ?? "-")
                    }
                }

                LabeledContent("Account") {
                    Text(transaction.account?.name ?? "-")
                }

                if let note = transaction.note, !note.isEmpty {
                    LabeledContent("Note") {
                        Text(note)
                    }
                }

                LabeledContent("Date") {
                    Text(formattedDate)
                }
            }

            Section {
                Button(role: .destructive, action: { showDeleteConfirm = true }) {
                    Label("Delete Transaction", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Transaction", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteTransaction(id: transaction.id) {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This will permanently delete this transaction.")
        }
    }

    private var formattedAmount: String {
        let amount = transaction.amountDouble
        let prefix = transaction.type == .expense ? "-" : "+"
        return "\(prefix)Rp \(Int(amount).formatted())"
    }

    private var formattedDate: String {
        guard let date = ISO8601DateFormatter().date(from: transaction.date) else {
            return transaction.date
        }
        return date.formatted(date: .long, time: .shortened)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(
                id: "1",
                accountId: "1",
                categoryId: "1",
                amount: "50000",
                type: .expense,
                note: "Lunch with client",
                date: ISO8601DateFormatter().string(from: Date()),
                account: nil,
                category: Category(id: "1", userId: "1", name: "Food", type: .expense, icon: "fork.knife", createdAt: nil),
                createdAt: nil
            ),
            viewModel: ActivityViewModel()
        )
    }
}