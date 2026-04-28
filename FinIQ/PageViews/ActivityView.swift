//
//  LedgerView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI
import SwiftData

struct ActivityView: View {
    @State private var searchText: String = ""
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    
    private var filteredActivities: [Activity] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !query.isEmpty else {
            return activities
        }
        
        return activities.filter { activity in
            activity.category.localizedCaseInsensitiveContains(query) || activity.note.localizedCaseInsensitiveContains(query)
        }
    }
    
    private var activityDays: [ActivityDay] {
        Dictionary(grouping: filteredActivities) { activity in
            Calendar.current.startOfDay(for: activity.date)
        }
        .map { ActivityDay(day: $0.key, activities: $0.value.sorted { $0.date > $1.date }) }
        .sorted { $0.day > $1.day }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Activity")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 32, weight: .semibold, design: .default))
                .foregroundColor(.onSurface)
                .padding(.top, 24)
            
            SearchBar(searchText: $searchText)
            
            if (filteredActivities.isEmpty) {
                let isSearching = !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let icon = isSearching ? "receipt.fill" : "magnifyingglass"
                let title = isSearching ? "Your activity is empty." : "No results found"
                let description = isSearching ? "Tap the + button to log your first expense or income." : "We couldn't find any activities matching your search. Try a different keyword"
                EmptyState(
                    icon: icon, title: title, description: description
                )
                .frame(maxHeight: .infinity)
                
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(activityDays) { activityDay in
                            VStack(spacing: 8) {
                                Text(label(for: activityDay.day))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.headline)
                                    .foregroundColor(.onSurface)
                                
                                ForEach(activityDay.activities) { activity in
                                    ActivityItem(activity: activity)
                                }
                            }
                        }
                    }
                }
            }
            
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .modifier(BackgroundMesh())
    }
    
    private func label(for day: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(day) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(day) {
            return "Yesterday"
        }
        
        return day.formatted(date: .long, time: .omitted)
    }
}

private struct ActivityDay: Identifiable {
    let day: Date
    let activities: [Activity]
    
    var id: Date { day }
}

#Preview {
    ActivityView()
}
