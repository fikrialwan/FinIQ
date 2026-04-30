//
//  AccountDetailView.swift
//  FinIQ
//
//  Account detail and edit screen
//

import SwiftUI

struct AccountDetailView: View {
    var account: Account
    @Bindable var viewModel: AccountViewModel
    @State private var showEdit = false
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(account.name)
                        .font(.title.bold())

                    HStack {
                        Image(systemName: account.type.icon)
                        Text(account.type.displayName)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Balance") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Balance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Rp \(Int(account.balanceDouble).formatted())")
                        .font(.title2.bold())
                }

                if let safeToSpend = account.safeToSpend {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Safe to Spend")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Rp \(Int(Double(safeToSpend) ?? 0).formatted())")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }

            Section {
                Button(action: { showEdit = true }) {
                    Label("Edit Account", systemImage: "pencil")
                }

                Button(role: .destructive, action: { showDeleteConfirm = true }) {
                    Label("Delete Account", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            EditAccountView(account: account, viewModel: viewModel)
        }
        .alert("Delete Account", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteAccount(id: account.id) {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This will permanently delete this account and all associated transactions.")
        }
    }
}

struct EditAccountView: View {
    var account: Account
    @Bindable var viewModel: AccountViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var type: AccountType = .cash
    @State private var balance: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(AccountType.allCases, id: \.self) { accType in
                            Text(accType.displayName).tag(accType)
                        }
                    }
                }

                Section("Balance") {
                    TextField("Balance", text: $balance)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isLoading = true
                            let balanceValue = balance.isEmpty ? nil : balance
                            let success = await viewModel.updateAccount(
                                id: account.id,
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
            .onAppear {
                name = account.name
                type = account.type
                balance = account.balance
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountDetailView(
            account: Account(
                id: "1",
                userId: "1",
                name: "Bank BCA",
                type: .bank,
                balance: "5000000",
                safeToSpend: "4500000"
            ),
            viewModel: AccountViewModel()
        )
    }
}