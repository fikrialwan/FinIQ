//
//  AccountListView.swift
//  FinIQ
//
//  Account list screen
//

import SwiftUI

struct AccountListView: View {
    @State private var viewModel = AccountViewModel()
    @State private var showAddAccount = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.accounts.isEmpty {
                ContentUnavailableView(
                    "No Accounts",
                    systemImage: "creditcard",
                    description: Text("Add your first account to start tracking")
                )
            } else {
                List {
                    Section {
                        ForEach(viewModel.accounts) { account in
                            NavigationLink(destination: AccountDetailView(account: account, viewModel: viewModel)) {
                                AccountRowView(account: account)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    let account = viewModel.accounts[index]
                                    await viewModel.deleteAccount(id: account.id)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Total: Rp \(Int(viewModel.totalBalance).formatted())")
                                .font(.caption)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddAccount = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddAccount) {
            AddAccountView(viewModel: viewModel)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadAccounts()
        }
    }
}

struct AccountRowView: View {
    var account: Account

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: account.type.icon)
                .font(.title2)
                .foregroundColor(.primaryTeal)
                .frame(width: 44, height: 44)
                .background(Color.primaryTeal.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.headline)
                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Rp \(Int(account.balanceDouble).formatted())")
                    .font(.headline)
                    .foregroundColor(account.balanceDouble >= 0 ? .primary : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AccountListView()
    }
}