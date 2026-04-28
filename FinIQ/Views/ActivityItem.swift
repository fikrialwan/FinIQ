//
//  ActivityItem.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 28/04/26.
//

import SwiftUI

struct ActivityItem: View {
    var activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon(for: activity.category))
                .frame(width: 35, height: 35)
                .foregroundColor(.onSurface)
                .modifier(GlassPanel(cornerRadius: 8))
                .padding(.trailing, 6)
            
            VStack(alignment: .leading) {
                Text(activity.category.capitalized)
                    .font(.caption)
                    .foregroundColor(.onSurface)
                Text("\(activity.note.isEmpty ? "" : "\(activity.note) • ")\(activity.date.formatted(date: .omitted,time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("\(activity.type == .expense ? "-" : "+")Rp \(activity.amount.formatted())")
                .font(.title3)
                .foregroundColor(activity.type == .expense ? .onSurface : .primaryTeal)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .modifier(GlassPanel(cornerRadius: 12))
    }
}

#Preview {
    ActivityItem(activity: Activity(
        amount: 50000, type: TransactionType.income, category: "Salary", note: "from facebook", date: .now
    )).modifier(BackgroundMesh())
    
    ActivityItem(activity: Activity(
        amount: 50000, type: TransactionType.expense, category: "Food", note: "", date: .now
    )).modifier(BackgroundMesh())
}
