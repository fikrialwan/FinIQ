//
//  ContentView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView().tag(Tabs.home).toolbar(.hidden, for: .tabBar)
                
                ActivityView().tag(Tabs.activity).toolbar(.hidden, for: .tabBar)
            }
            .padding(.bottom, 1)
            
            FloatingNewTransactionButton()
        }
        .safeAreaInset(edge: .bottom) {
            BottomNavBar(selectedTab: $selectedTab)
        }
        .modifier(BackgroundMesh())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Activity.self)
}
