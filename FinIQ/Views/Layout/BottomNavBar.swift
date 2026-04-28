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
            BottomNavBarItem(icon: "square.grid.2x2.fill", title: "IQ", tab: Tabs.home, selectedTab: $selectedTab)
            BottomNavBarItem(icon: "list.bullet.rectangle", title: "ACTIVITY", tab: Tabs.activity, selectedTab: $selectedTab)
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

#Preview {
    @Previewable @State var selectedTab: Tabs = .home
    
    BottomNavBar(selectedTab: $selectedTab).modifier(BackgroundMesh())
}
