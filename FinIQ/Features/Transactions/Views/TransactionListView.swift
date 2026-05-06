import SwiftUI

struct TransactionListView: View {
    @State private var viewModel = TransactionViewModel()
    @State private var showAddTransaction = false
    @State private var searchText = ""

    var body: some View {
        Group {
            if viewModel.transactions.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                transactionsList
            }
        }
        .navigationTitle("Transactions")
        .searchable(text: $searchText, prompt: "Search transactions")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.resetForm()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: viewModel, accounts: viewModel.accounts)
        }
        .task {
            await viewModel.loadTransactions()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Transactions",
            systemImage: "list.bullet.rectangle",
            description: Text("Add your first transaction to start tracking")
        )
    }

    private var transactionsList: some View {
        List {
            ForEach(groupedTransactions.keys.sorted(by: >), id: \.self) { date in
                Section(date.formatted(date: .abbreviated, time: .omitted)) {
                    ForEach(groupedTransactions[date] ?? []) { transaction in
                        TransactionRowView(transaction: transaction)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteTransaction(transaction) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadTransactions()
        }
    }

    private var groupedTransactions: [Date: [Transaction]] {
        let calendar = Calendar.current
        return Dictionary(grouping: filteredTransactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }
    }

    private var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return viewModel.transactions
        }
        return viewModel.transactions.filter { transaction in
            transaction.note?.localizedCaseInsensitiveContains(searchText) == true ||
            transaction.account?.name.localizedCaseInsensitiveContains(searchText) == true ||
            transaction.category?.name.localizedCaseInsensitiveContains(searchText) == true
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let category = transaction.category {
                        Text(category.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    } else {
                        Text(transaction.type.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    if transaction.type == .expense {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else if transaction.type == .income {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                if let account = transaction.account {
                    Text(account.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(formatAmount(transaction.amount, type: transaction.type))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(colorForType(transaction.type))
        }
        .padding(.vertical, 4)
    }

    private func formatAmount(_ amount: String, type: TransactionType) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        if let decimal = Decimal(string: amount) {
            let formatted = formatter.string(from: decimal as NSDecimalNumber) ?? amount
            return type == .expense ? "-\(formatted)" : "+\(formatted)"
        }
        return amount
    }

    private func colorForType(_ type: TransactionType) -> Color {
        switch type {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}

struct AddTransactionView: View {
    @Bindable var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showRoundUpInfo = false
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryType: CategoryType = .expense
    @State private var newCategoryIcon = ""

    let accounts: [Account]

    init(viewModel: TransactionViewModel, accounts: [Account]) {
        self._viewModel = Bindable(wrappedValue: viewModel)
        self.accounts = accounts
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Transaction Type", selection: $viewModel.type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)

                    Picker("Account", selection: $viewModel.selectedAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account.id as String?)
                        }
                    }

                    if viewModel.type != .transfer {
                        Picker("Category", selection: $viewModel.selectedCategoryId) {
                            Text("Select Category").tag(nil as String?)
                            ForEach(viewModel.filteredCategories) { category in
                                Text(category.name).tag(category.id as String?)
                            }
                        }
                        Button {
                            newCategoryType = viewModel.type == .income ? .income : .expense
                            showAddCategory = true
                        } label: {
                            Label("Add Category", systemImage: "plus.circle")
                        }
                    }

                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)

                    TextField("Note (optional)", text: $viewModel.note)
                }

                if viewModel.type == .expense {
                    Section {
                        Toggle("Round up for savings", isOn: $showRoundUpInfo)
                        if showRoundUpInfo {
                            Text("Round up your expense to the nearest integer and automatically save the difference to your General Savings goal.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if await viewModel.createTransaction() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.selectedAccountId == nil || viewModel.amount.isEmpty || viewModel.isLoading)
                }
            }
            .onChange(of: viewModel.type) { _, _ in
                viewModel.selectedCategoryId = nil
            }
        }
        .task {
            await viewModel.loadCategories()
        }
        .sheet(isPresented: $showAddCategory) {
            NavigationStack {
                Form {
                    TextField("Category Name", text: $newCategoryName)
                    Picker("Type", selection: $newCategoryType) {
                        Text("Expense").tag(CategoryType.expense)
                        Text("Income").tag(CategoryType.income)
                    }
                    TextField("Icon (optional)", text: $newCategoryIcon)
                }
                .navigationTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            newCategoryName = ""
                            newCategoryIcon = ""
                            showAddCategory = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                if let newCat = await viewModel.createCategory(
                                    name: newCategoryName,
                                    type: newCategoryType,
                                    icon: newCategoryIcon.isEmpty ? nil : newCategoryIcon
                                ) {
                                    newCategoryName = ""
                                    newCategoryIcon = ""
                                    showAddCategory = false
                                    viewModel.selectedCategoryId = newCat.id
                                }
                            }
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}