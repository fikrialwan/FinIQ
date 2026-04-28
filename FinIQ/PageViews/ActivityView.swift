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
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Activity")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 32, weight: .semibold, design: .default))
                .foregroundColor(.onSurface)
                .padding(.top, 24)
            
            SearchBar(searchText: $searchText)
            
            if (activities.isEmpty) {
                EmptyState()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    ForEach(activities) { activity in
                        ActivityItem(activity: activity)
                    }
                }
            }
            

        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 20)
        .modifier(BackgroundMesh())
    }
}

#Preview {
    ActivityView()
}
