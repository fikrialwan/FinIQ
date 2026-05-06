import SwiftUI

@main
struct FinIQApp: App {
    @State private var authViewModel = AuthViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(authViewModel: authViewModel)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
    }

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            break
        case .inactive:
            break
        case .active:
            break
        @unknown default:
            break
        }
    }
}

struct ContentView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isAuthenticated {
            MainTabView()
                .environment(authViewModel)
        } else {
            LoginView(viewModel: authViewModel)
        }
    }
}

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var showNetworkLogs = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showNetworkLogs: $showNetworkLogs, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            GoalListView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)

            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .tint(.teal)
        .sheet(isPresented: $showNetworkLogs) {
            NetworkLogView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh data when app becomes active
            }
        }
    }
}