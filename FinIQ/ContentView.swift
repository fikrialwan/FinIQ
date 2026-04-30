//
//  ContentView.swift
//  FinIQ
//
//  Main app container with tab navigation
//

import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView(authViewModel: authViewModel)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)

                    NavigationStack {
                        AccountListView()
                    }
                    .tabItem {
                        Label("Accounts", systemImage: "creditcard")
                    }
                    .tag(1)

                    NavigationStack {
                        TransactionListView()
                    }
                    .tabItem {
                        Label("Transactions", systemImage: "list.bullet")
                    }
                    .tag(2)

                    NavigationStack {
                        AnalyticsDashboardView()
                    }
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
                    .tag(3)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}