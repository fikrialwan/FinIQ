//
//  TransferView.swift
//  FinIQ
//
//  Transfer between accounts screen
//

import SwiftUI

struct TransferView: View {
    @State private var viewModel = TransferViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var fromAccountId: String?
    @State private var toAccountId: String?
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("From Account") {
                    Picker("Source Account", selection: $fromAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(viewModel.accounts) { account in
                            Text("\(account.name) - Rp \(Int(account.balanceDouble).formatted())")
                                .tag(account.id as String?)
                        }
                    }
                }

                Section("To Account") {
                    Picker("Destination Account", selection: $toAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(viewModel.accounts.filter { $0.id != fromAccountId }) { account in
                            Text("\(account.name) - Rp \(Int(account.balanceDouble).formatted())")
                                .tag(account.id as String?)
                        }
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

                Section("Note (optional)") {
                    TextField("Transfer note", text: $note)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Transfer") {
                        Task {
                            await performTransfer()
                        }
                    }
                    .disabled(!canTransfer || isLoading)
                }
            }
            .task {
                await viewModel.loadAccounts()
            }
        }
    }

    private var canTransfer: Bool {
        fromAccountId != nil &&
        toAccountId != nil &&
        fromAccountId != toAccountId &&
        !amount.isEmpty
    }

    private func performTransfer() async {
        guard let fromId = fromAccountId,
              let toId = toAccountId,
              let amountValue = Int(amount) else { return }

        isLoading = true
        errorMessage = nil

        let success = await viewModel.transfer(
            fromAccountId: fromId,
            toAccountId: toId,
            amount: String(amountValue),
            note: note.isEmpty ? nil : note,
            date: ISO8601DateFormatter().string(from: date)
        )

        isLoading = false

        if success {
            dismiss()
        } else {
            errorMessage = viewModel.errorMessage
        }
    }
}

#Preview {
    TransferView()
}