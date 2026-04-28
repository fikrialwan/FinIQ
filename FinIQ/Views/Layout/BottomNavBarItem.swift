//
//  BottomNavBarItem.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 28/04/26.
//

import SwiftUI

struct BottomNavBarItem: View {
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
    
    BottomNavBarItem(icon: "square.grid.2x2.fill", title: "IQ", tab: Tabs.home, selectedTab: $selectedTab)
    BottomNavBarItem(icon: "list.bullet.rectangle", title: "ACTIVITY", tab: Tabs.activity, selectedTab: $selectedTab)
}
