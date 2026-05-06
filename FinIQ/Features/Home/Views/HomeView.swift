import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var showAddTransaction = false
    @State private var showAddAccount = false
    @State private var showTransfer = false
    @Binding var showNetworkLogs: Bool
    @Binding var selectedTab: Int

    init(showNetworkLogs: Binding<Bool> = .constant(false), selectedTab: Binding<Int> = .constant(0)) {
        self._showNetworkLogs = showNetworkLogs
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isOffline {
                            offlineBanner
                        }

                        netWorthCard

                        safeToSpendCard

                        quickActionsSection

                        recentAccountsSection

                        goalsSection
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            showNetworkLogs = true
                        } label: {
                            Image(systemName: "network")
                        }

                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(viewModel: TransactionViewModel(), accounts: viewModel.accounts)
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView(viewModel: AccountViewModel(), isEditing: false)
            }
            .sheet(isPresented: $showTransfer) {
                TransferView()
            }
            .task {
                await viewModel.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .transactionDidChange)) { _ in
                Task { await viewModel.refresh() }
            }
        }
    }

    private var offlineBanner: some View {
        HStack {
            Image(systemName: "wifi.slash")
            Text("You're offline. Showing cached data.")
        }
        .font(.caption)
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.2))
        .foregroundStyle(.orange)
        .cornerRadius(8)
    }

    private var netWorthCard: some View {
        VStack(spacing: 8) {
            Text("Total Net Worth")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(formatCurrency(viewModel.totalNetWorth))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var safeToSpendCard: some View {
        VStack(spacing: 8) {
            Text("Safe to Spend")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(formatCurrency(viewModel.safeToSpend))
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.teal)

            HStack {
                Text("Allocated to goals:")
                Text(formatCurrency(viewModel.totalAllocatedToGoals))
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.teal.opacity(0.1))
        .cornerRadius(16)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Add Expense",
                    icon: "minus.circle.fill",
                    color: .red
                ) {
                    showAddTransaction = true
                }

                QuickActionButton(
                    title: "Add Income",
                    icon: "plus.circle.fill",
                    color: .green
                ) {
                    showAddTransaction = true
                }

                QuickActionButton(
                    title: "Transfer",
                    icon: "arrow.left.arrow.right.circle.fill",
                    color: .blue
                ) {
                    showTransfer = true
                }
            }
        }
    }

    private var recentAccountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                Spacer()
                Button("Add") {
                    showAddAccount = true
                }
                .font(.subheadline)
            }

            if viewModel.accounts.isEmpty {
                Text("No accounts yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.accounts.prefix(3)) { account in
                    AccountRowView(account: account)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    selectedTab = 2
                }
                .font(.subheadline)
            }

            if viewModel.goals.isEmpty {
                Text("No goals yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.goals.prefix(3)) { goal in
                    GoalRowView(goal: goal)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "Rp 0"
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct AccountRowView: View {
    let account: Account

    var body: some View {
        HStack {
            Image(systemName: iconForType(account.type))
                .foregroundStyle(.teal)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.subheadline)
                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(formatBalance(account.balance))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }

    private func iconForType(_ type: AccountType) -> String {
        switch type {
        case .cash: return "banknote"
        case .bank: return "building.columns"
        case .creditCard: return "creditcard"
        case .digitalWallet: return "iphone"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
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

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(goal.percentageComplete)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(goal.percentageComplete) ?? 0, total: 100)
                .tint(.teal)

            HStack {
                Text("Rp \(goal.currentAmount)")
                    .font(.caption)
                Text("of Rp \(goal.targetAmount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}