//
//  BottomNavBar.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 27/04/26.
//

import SwiftUI

enum Tabs: Equatable, Hashable {
    case home
    case activity
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tabs
    
    var body: some View {
        HStack(spacing: 0) {
            NavBarBottom(icon: "square.grid.2x2.fill", title: "IQ", tab: Tabs.home, selectedTab: $selectedTab)
            NavBarBottom(icon: "list.bullet.rectangle", title: "ACTIVITY", tab: Tabs.activity, selectedTab: $selectedTab)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 40)
        .background(Color.white.opacity(0.05))
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)),
            alignment: .top
        )
    }
}

struct NavBarBottom: View {
    let icon: String
    let title: String
    let tab: Tabs
    
    @Binding var selectedTab: Tabs
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(1)
            }
            .foregroundColor(selectedTab == tab ? .primaryTeal : Color.white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .shadow(color: selectedTab == tab ? .primaryTeal.opacity(0.4) : .clear, radius: 8, x: 0, y: 0)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab: Tabs = .home
    
    BottomNavBar(selectedTab: $selectedTab).modifier(BackgroundMesh())
}
