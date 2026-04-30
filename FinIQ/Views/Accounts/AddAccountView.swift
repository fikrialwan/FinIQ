//
//  AddAccountView.swift
//  FinIQ
//
//  Add new account screen
//

import SwiftUI

struct AddAccountView: View {
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var type: AccountType = .bank
    @State private var balance: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(AccountType.allCases, id: \.self) { accType in
                            Label(accType.displayName, systemImage: accType.icon)
                                .tag(accType)
                        }
                    }
                }

                Section("Initial Balance") {
                    TextField("Balance (optional)", text: $balance)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            isLoading = true
                            let balanceValue = balance.isEmpty ? nil : balance
                            let success = await viewModel.createAccount(
                                name: name,
                                type: type,
                                balance: balanceValue
                            )
                            isLoading = false
                            if success { dismiss() }
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }
}

#Preview {
    AddAccountView(viewModel: AccountViewModel())
}