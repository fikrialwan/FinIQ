import SwiftUI

struct GoalListView: View {
    @State private var viewModel = GoalViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.goals.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    goalsList
                }
            }
            .navigationTitle("Savings Goals")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.resetForm()
                        viewModel.showAddGoal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Goal")
                }
            }
            .sheet(isPresented: $viewModel.showAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showDepositSheet) {
                DepositToGoalView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadGoals()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Goals", systemImage: "target")
        } description: {
            Text("Create your first savings goal to start allocating funds")
        } actions: {
            Button("Add Goal") {
                viewModel.resetForm()
                viewModel.showAddGoal = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
    }

    private var goalsList: some View {
        List {
            ForEach(viewModel.goals) { goal in
                GoalCardView(goal: goal) {
                    viewModel.startDeposit(for: goal)
                }
            }
        }
        .refreshable {
            await viewModel.loadGoals()
        }
    }
}

struct GoalCardView: View {
    let goal: Goal
    let onDeposit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)

                    if let targetDate = goal.targetDate {
                        Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(goal.percentageComplete)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.teal)
            }

            ProgressView(value: Double(goal.percentageComplete) ?? 0, total: 100)
                .tint(.teal)

            HStack {
                VStack(alignment: .leading) {
                    Text("Saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Rp \(goal.currentAmount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Rp \(goal.remainingAmount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            Button("Deposit") {
                onDeposit()
            }
            .buttonStyle(.bordered)
            .tint(.teal)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.vertical, 4)
    }
}

struct AddGoalView: View {
    @Bindable var viewModel: GoalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal Details") {
                    TextField("Goal Name", text: $viewModel.name)

                    TextField("Target Amount", text: $viewModel.targetAmount)
                        .keyboardType(.decimalPad)

                    Toggle("Set Target Date", isOn: $viewModel.hasTargetDate)

                    if viewModel.hasTargetDate {
                        DatePicker("Target Date", selection: $viewModel.targetDate, displayedComponents: .date)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetForm()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if await viewModel.createGoal() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.targetAmount.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

struct DepositToGoalView: View {
    @Bindable var viewModel: GoalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if let goal = viewModel.selectedGoal {
                    Section("Goal") {
                        Text(goal.name)
                            .font(.headline)
                    }
                }

                Section("Deposit") {
                    TextField("Amount", text: $viewModel.depositAmount)
                        .keyboardType(.decimalPad)

                    Picker("From Account", selection: $viewModel.depositAccountId) {
                        Text("Select Account").tag(nil as String?)
                        ForEach(viewModel.accounts) { account in
                            Text(account.name).tag(account.id as String?)
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
            .navigationTitle("Deposit to Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.resetDepositForm()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Deposit") {
                        Task {
                            if await viewModel.depositToGoal() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.depositAccountId == nil || viewModel.depositAmount.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

struct GoalDetailView: View {
    let goal: Goal
    @State private var viewModel = GoalViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Progress") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Rp \(goal.currentAmount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(goal.percentageComplete)%")
                            .font(.title2)
                            .foregroundStyle(.teal)
                    }

                    ProgressView(value: Double(goal.percentageComplete) ?? 0, total: 100)
                        .tint(.teal)

                    Text("of Rp \(goal.targetAmount)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Details") {
                LabeledContent("Name", value: goal.name)
                if let targetDate = goal.targetDate {
                    LabeledContent("Target Date", value: targetDate.formatted(date: .abbreviated, time: .omitted))
                }
                if let daysRemaining = goal.daysRemaining {
                    LabeledContent("Days Remaining", value: "\(daysRemaining)")
                }
                LabeledContent("Remaining Amount", value: "Rp \(goal.remainingAmount)")
            }

            Section {
                Button("Deposit") {
                    viewModel.startDeposit(for: goal)
                    viewModel.showDepositSheet = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(goal.name)
        .sheet(isPresented: $viewModel.showDepositSheet) {
            DepositToGoalView(viewModel: viewModel)
        }
    }
}