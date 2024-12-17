import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var selectedDashboard: Dashboard?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedDashboard: $selectedDashboard)
                .tabItem {
                    Label {
                        Text("Dashboard")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 0, type: .dashboard)
                    }
                }
                .tag(0)
            
            JournalView(selectedDashboard: $selectedDashboard)
                .tabItem {
                    Label {
                        Text("Journal")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 1, type: .journal)
                    }
                }
                .tag(1)
            
            TradesView(selectedDashboard: $selectedDashboard)
                .tabItem {
                    Label {
                        Text("Trades")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 2, type: .trades)
                    }
                }
                .tag(2)
        }
        .tint(AppTheme.primaryColor)
        .preferredColorScheme(.dark)
    }
}
