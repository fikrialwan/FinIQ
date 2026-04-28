//
//  HomeView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: Tabs
    @Query private var homeSummaries: [HomeSummary]
    @Query private var activities: [Activity]

    private var homeSummary: HomeSummary? {
        homeSummaries.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeroCard(totalWealth: homeSummary?.balance ?? 0, iqScore: homeSummary?.iqScore ?? 0, hasActivity: !activities.isEmpty)
                RecentActivityCard(selectedTab: $selectedTab)
            }.padding(.horizontal, 20)
                .padding(.vertical, 24)
        }
        .modifier(BackgroundMesh())

    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .home
    HomeView(selectedTab: $selectedTab)
        .modelContainer(for: [Activity.self, HomeSummary.self])
}
