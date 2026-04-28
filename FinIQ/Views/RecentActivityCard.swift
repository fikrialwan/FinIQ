//
//  SwiftUIView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI
import SwiftData

struct RecentActivityCard: View {
    @Binding var selectedTab: Tabs
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.onSurface)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                Button {
                    selectedTab = .activity
                } label: {
                    HStack {
                        Text("View All")
                        Image(systemName: "arrow.right")
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primaryTeal)
            }
            if (activities.isEmpty) {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 24))
                        .foregroundColor(.onSurfaceVariant)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                        .padding(.bottom, 8)
                    
                    Text("It's empty here")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.onSurface)
                    
                    Text("Transactions will appear once you add them.")
                        .font(.system(size: 14))
                        .foregroundColor(.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
                .modifier(GlassCard())
            } else {
                VStack(spacing: 12) {
                    ForEach(activities.prefix(4), id: \.id) { activity in
                        RecentActivityItem(activity: activity, lastActivityId: activities.prefix(4).last!.id)
                    }
                }
                .frame(maxWidth: .infinity)
                .modifier(GlassCard())
            }
            
        }
    }
}

struct RecentActivityItem: View {
    var activity: Activity
    var lastActivityId: UUID
    
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
                if (!activity.note.isEmpty) {
                    Text(activity.note)
                        .font(.caption2)
                        .foregroundColor(.onSurfaceVariant)
                }
                Text(activity.date.formatted(date: .long,time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.onSurfaceVariant)
            }
            
            Text("\(activity.type == .expense ? "-" : "+")Rp \(activity.amount.formatted())")
                .font(.title3)
                .foregroundColor(activity.type == .expense ? .onSurface : .primaryTeal)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.bottom, activity.id != lastActivityId ? 8 : 0)
        .overlay(
            alignment: .bottom
        ) {
            if activity.id != lastActivityId {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.2))
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .home
    RecentActivityCard(selectedTab: $selectedTab).modifier(BackgroundMesh())
}
