//
//  ContentView.swift
//  FinIQ
//
//  Created by Fikri Alwan Ramadhan on 26/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        ZStack(alignment: .bottom){
            TabView(selection: $selectedTab) {
                HomeView().tag(Tabs.home).toolbar(.hidden, for: .tabBar)
                
                LedgerView().tag(Tabs.ledger).toolbar(.hidden, for: .tabBar)
            }
            .padding(.bottom, 1)
            
            FloatingNewTransactionButton()
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 0) {
                Button(action: {
                    selectedTab = .home
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 24))
                        Text("IQ")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(1)
                    }
                    .foregroundColor(selectedTab == .home ? .primaryTeal : Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .shadow(color: selectedTab == .ledger ? .primaryTeal.opacity(0.4) : .clear, radius: 8, x: 0, y: 0)
                }
                
                Button(action: {
                    selectedTab = .ledger
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 24))
                        Text("LEDGER")
                            .font(.system(size: 10, weight: .medium))
                            .tracking(1)
                    }
                    // Dynamic styling based on selection
                    .foregroundColor(selectedTab == .ledger ? .primaryTeal : Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .shadow(color: selectedTab == .ledger ? .primaryTeal.opacity(0.4) : .clear, radius: 8, x: 0, y: 0)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 40)
            .background(Color.white.opacity(0.05))
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.2)),
                alignment: .top
            )
        }
        .modifier(BackgroundMesh())
    }
}

#Preview {
    ContentView()
}
