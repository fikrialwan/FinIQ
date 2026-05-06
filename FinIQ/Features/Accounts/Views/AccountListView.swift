import SwiftUI

struct AccountListView: View {
    @State private var viewModel = AccountViewModel()

    var body: some View {
        Group {
            if viewModel.accounts.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                accountsList
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.resetForm()
                    viewModel.showAddAccount = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddAccount) {
            AddAccountView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditAccount) {
            AddAccountView(viewModel: viewModel, isEditing: true)
        }
        .task {
            await viewModel.loadAccounts()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Accounts",
            systemImage: "creditcard",
            description: Text("Add your first account to start tracking")
        )
    }

    private var accountsList: some View {
        List {
            ForEach(AccountType.allCases, id: \.self) { type in
                let accountsOfType = viewModel.accounts.filter { $0.type == type }
                if !accountsOfType.isEmpty {
                    Section(type.displayName) {
                        ForEach(accountsOfType) { account in
                            NavigationLink {
                                AccountDetailView(account: account, viewModel: viewModel)
                            } label: {
                                AccountRowView(account: account)
                            }
                        }
                        .onDelete { indexSet in
                            deleteAccounts(ofType: type, at: indexSet)
                        }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadAccounts()
        }
    }

    private func deleteAccounts(ofType type: AccountType, at offsets: IndexSet) {
        let accountsOfType = viewModel.accounts.filter { $0.type == type }
        for index in offsets {
            let account = accountsOfType[index]
            Task {
                await viewModel.deleteAccount(account)
            }
        }
    }
}

struct AccountDetailView: View {
    let account: Account
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Name", value: account.name)
                LabeledContent("Type", value: account.type.displayName)
                LabeledContent("Balance", value: formatBalance(account.balance))
            }

            Section {
                Button("Edit") {
                    viewModel.editAccount(account)
                }

                Button("Delete", role: .destructive) {
                    Task {
                        if await viewModel.deleteAccount(account) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .navigationTitle(account.name)
    }

    private func formatBalance(_ balance: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        if let decimal = Decimal(string: balance) {
            return formatter.string(from: decimal as NSDecimalNumber) ?? balance
        }
        return balance
    }
}

struct AddAccountView: View {
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss
    let isEditing: Bool

    init(viewModel: AccountViewModel, isEditing: Bool = false) {
        self._viewModel = Bindable(wrappedValue: viewModel)
        self.isEditing = isEditing
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $viewModel.name)

                    Picker("Type", selection: $viewModel.type) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    TextField("Initial Balance", text: $viewModel.balance)
                        .keyboardType(.decimalPad)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Account" : "Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        Task {
                            let success: Bool
                            if isEditing {
                                success = await viewModel.updateAccount()
                            } else {
                                success = await viewModel.createAccount()
                            }
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}