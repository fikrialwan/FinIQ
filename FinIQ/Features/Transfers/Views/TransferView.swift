import SwiftUI

struct TransferView: View {
    @State private var viewModel = TransferViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("From") {
                    Picker("Source Account", selection: $viewModel.fromAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(viewModel.accounts) { account in
                            Text("\(account.name) (\(formatBalance(account.balance)))").tag(account.id as String?)
                        }
                    }
                }

                Section("To") {
                    Picker("Destination Account", selection: $viewModel.toAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(viewModel.accounts.filter { $0.id != viewModel.fromAccountId }) { account in
                            Text("\(account.name) (\(formatBalance(account.balance)))").tag(account.id as String?)
                        }
                    }
                }

                Section("Details") {
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)

                    TextField("Note (optional)", text: $viewModel.note)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Transfer") {
                        Task {
                            if await viewModel.createTransfer() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                }
            }
            .task {
                await viewModel.loadAccounts()
            }
        }
    }

    private var isFormValid: Bool {
        viewModel.fromAccountId != nil &&
        viewModel.toAccountId != nil &&
        viewModel.fromAccountId != viewModel.toAccountId &&
        !viewModel.amount.isEmpty
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