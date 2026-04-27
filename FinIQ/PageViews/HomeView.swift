//
//  HomeView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeroCard()
                RecentActivityCard()
            }.padding(.horizontal, 20)
                .padding(.vertical, 24)
        }
        .modifier(BackgroundMesh())

    }
}

#Preview {
    HomeView()
}
