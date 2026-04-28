//
//  HomeSummary.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 28/04/26.
//

import SwiftData

@Model
class HomeSummary {
    var balance: Int
    var totalIncome: Int
    var totalExpenses: Int
    var iqScore: Int

    init(balance: Int = 0, totalIncome: Int = 0, totalExpenses: Int = 0, iqScore: Int = 0) {
        self.balance = balance
        self.totalIncome = totalIncome
        self.totalExpenses = totalExpenses
        self.iqScore = iqScore
    }

    func recalculate(from activities: [Activity]) {
        totalIncome = activities.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        totalExpenses = activities.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        balance = totalIncome - totalExpenses
        iqScore = calculateIQScore()
    }

    private func calculateIQScore() -> Int {
        let totalIncome = Double(totalIncome)
        let totalBudget = totalIncome
        let totalExpenses = Double(totalExpenses)

        guard totalIncome > 0, totalBudget > 0 else { return 0 }

        let budgetRemaining = max(0, totalBudget - totalExpenses)
        let consistency = (budgetRemaining / totalBudget) * 100

        let savings = max(0, totalIncome - totalExpenses)
        let savingsRatio = (savings / totalIncome) * 100

        let finalScore = (consistency * 0.6) + (savingsRatio * 0.4)
        return Int(finalScore)
    }
}
