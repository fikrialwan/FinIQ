//
//  HomeView.swift
//  FinIQ
//
//  Home dashboard screen
//

import SwiftUI

struct HomeView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var viewModel = HomeViewModel()
    @State private var showAddTransaction = false
    @State private var showLogoutConfirm = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Balance Overview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Balance")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("Rp \(Int(viewModel.totalBalance).formatted())")
                                .font(.largeTitle.bold())

                            Text("IQ Score: \(viewModel.iqScore)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Quick Actions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.headline)

                            HStack(spacing: 12) {
                                Button(action: { showAddTransaction = true }) {
                                    QuickActionButton(icon: "plus.circle.fill", title: "Add", color: .green)
                                }

                                NavigationLink(destination: TransferView()) {
                                    QuickActionButton(icon: "arrow.left.arrow.right.circle.fill", title: "Transfer", color: .blue)
                                }

                                NavigationLink(destination: AccountListView()) {
                                    QuickActionButton(icon: "creditcard.fill", title: "Accounts", color: .purple)
                                }
                            }
                        }

                        // Recent Transactions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Transactions")
                                    .font(.headline)
                                Spacer()
                                NavigationLink(destination: TransactionListView()) {
                                    Text("See All")
                                        .font(.caption)
                                }
                            }

                            if viewModel.recentTransactions.isEmpty {
                                Text("No transactions yet")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(viewModel.recentTransactions.prefix(5)) { transaction in
                                    TransactionRowView(transaction: transaction)
                                        .padding(.vertical, 4)
                                        .overlay(alignment: .bottom) {
                                            if transaction.id != viewModel.recentTransactions.prefix(5).last?.id {
                                                Divider()
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("FinIQ")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showLogoutConfirm = true }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: ActivityViewModel())
        }
        .alert("Logout", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadData()
        }
    }
}

struct QuickActionButton: View {
    var icon: String
    var title: String
    var color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        HomeView(authViewModel: AuthViewModel())
    }
}