//
//  Activity.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 28/04/26.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    
    var icon: String {
        switch self {
        case .expense: return "arrow.up"
        case .income: return "arrow.down"
        }
    }
    
    var categories: [(String, String)] {
        switch self {
        case .expense: return [
            ("Food", "fork.knife"),
            ("Transport", "car.fill"),
            ("Shopping", "bag.fill"),
            ("Housing", "house.fill"),
            ("Subs", "play.tv.fill"),
            ("Health", "heart.text.square.fill"),
            ("Travel", "airplane"),
            ("Other", "square.grid.2x2.fill")
        ]
        case .income: return [
            ("Salary", "briefcase.fill"),
            ("Freelance", "laptopcomputer"),
            ("Investment", "chart.line.uptrend.xyaxis"),
            ("Gift", "gift"),
            ("Side Hustle", "storefront.fill"),
            ("Refund", "return"),
            ("Interest", "percent"),
            ("Other", "square.grid.2x2.fill")
        ]
        }
    }
    
    func icon(for categoryName: String) -> String {
        if let matchedCategory = categories.first(where: { $0.0 == categoryName }) {
            return matchedCategory.1
        }
        
        return "square.grid.2x2.fill"
    }
}

@Model
class Activity {
    @Attribute(.unique) var id: UUID
    var amount: Int
    var type: TransactionType
    var category: String
    var note: String
    var date: Date
    
    init(amount: Int, type: TransactionType, category: String, note: String, date: Date = .now) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.date = date
    }
}
