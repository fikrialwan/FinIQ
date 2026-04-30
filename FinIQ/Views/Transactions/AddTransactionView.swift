//
//  AddTransactionView.swift
//  FinIQ
//
//  Add new transaction screen
//

import SwiftUI

struct AddTransactionView: View {
    @Bindable var viewModel: ActivityViewModel
    @Environment(\.dismiss) var dismiss

    @State private var type: TransactionType = .expense
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedAccountId: String?
    @State private var selectedCategoryId: String?
    @State private var date: Date = Date()
    @State private var isLoading = false

    var body: some View {
        Form {
            Section("Type") {
                Picker("Transaction Type", selection: $type) {
                    Text("Expense").tag(TransactionType.expense)
                    Text("Income").tag(TransactionType.income)
                }
                .pickerStyle(.segmented)
                .onChange(of: type) { _, _ in
                    selectedCategoryId = nil
                }
            }

            Section("Amount") {
                HStack {
                    Text("Rp")
                        .foregroundStyle(.secondary)
                    TextField("0", text: $amount)
                        .keyboardType(.numberPad)
                }
            }

            Section("Account") {
                Picker("From Account", selection: $selectedAccountId) {
                    Text("Select Account").tag(nil as String?)
                    ForEach(viewModel.accounts) { account in
                        Text(account.name).tag(account.id as String?)
                    }
                }
            }

            Section("Category") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                    ForEach(filteredCategories) { category in
                        CategoryChipView(
                            category: category,
                            isSelected: selectedCategoryId == category.id
                        ) {
                            selectedCategoryId = category.id
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Note (optional)") {
                TextField("Add note", text: $note)
            }

            Section("Date") {
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
        }
        .navigationTitle("New Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await saveTransaction()
                    }
                }
                .disabled(!canSave || isLoading)
            }
        }
        .onAppear {
            if selectedAccountId == nil {
                selectedAccountId = viewModel.accounts.first?.id
            }
        }
    }

    private var filteredCategories: [Category] {
        viewModel.categories.filter { $0.type.rawValue == type.rawValue }
    }

    private var canSave: Bool {
        !amount.isEmpty && selectedAccountId != nil && selectedCategoryId != nil
    }

    private func saveTransaction() async {
        guard let accountId = selectedAccountId,
              let categoryId = selectedCategoryId,
              let amountValue = Int(amount) else { return }

        isLoading = true
        let dateString = ISO8601DateFormatter().string(from: date)
        let success = await viewModel.addTransaction(
            accountId: accountId,
            amount: String(amountValue),
            type: type,
            categoryId: categoryId,
            note: note.isEmpty ? nil : note,
            date: dateString
        )
        isLoading = false
        if success { dismiss() }
    }
}

struct CategoryChipView: View {
    var category: Category
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon ?? "tag")
                    .font(.title3)
                Text(category.name)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(width: 70, height: 60)
            .foregroundStyle(isSelected ? .white : .primary)
            .background(isSelected ? Color.primaryTeal : Color.primaryTeal.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddTransactionView(viewModel: ActivityViewModel())
}