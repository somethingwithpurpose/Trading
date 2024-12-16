import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label {
                        Text("Dashboard")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 0, type: .dashboard)
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    }
                }
                .tag(0)
            
            JournalView()
                .tabItem {
                    Label {
                        Text("Journal")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 1, type: .journal)
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                    }
                }
                .tag(1)
            
            TradesView()
                .tabItem {
                    Label {
                        Text("Trades")
                    } icon: {
                        CustomTabIcon(isSelected: selectedTab == 2, type: .trades)
                            .environment(\.symbolVariants, selectedTab == 2 ? .fill : .none)
                    }
                }
                .tag(2)
        }
        .tint(AppTheme.primaryColor)
        .preferredColorScheme(.dark)
    }
} 