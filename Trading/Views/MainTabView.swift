import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var selectedDashboard: Dashboard?
    @State private var showingAddTrade = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedDashboard: $selectedDashboard)
                .tabItem {
                    Label {
                        Text("Dashboard")
                    } icon: {
                        Image(systemName: TradingIcon.dashboard.systemName)
                    }
                }
                .tag(0)
            
            JournalView(selectedDashboard: $selectedDashboard)
                .tabItem {
                    Label {
                        Text("Journal")
                    } icon: {
                        Image(systemName: TradingIcon.journal.systemName)
                    }
                }
                .tag(1)
            
            TradesView(selectedDashboard: $selectedDashboard, showingAddTrade: $showingAddTrade)
                .tabItem {
                    Label {
                        Text("Trades")
                    } icon: {
                        Image(systemName: TradingIcon.trades.systemName)
                    }
                }
                .tag(2)
        }
    }
}
