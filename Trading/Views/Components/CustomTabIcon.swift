import SwiftUI

struct CustomTabIcon: View {
    let isSelected: Bool
    let type: TabIcon
    
    enum TabIcon {
        case dashboard
        case journal
        case trades
    }
    
    var body: some View {
        switch type {
        case .dashboard:
            Image(systemName: "chart.xyaxis.line")
                .symbolEffect(.bounce, value: isSelected)
                .foregroundStyle(isSelected ? AppTheme.primaryColor : .gray)
                .imageScale(.large)
                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
            
        case .journal:
            Image(systemName: "book")
                .symbolEffect(.bounce, value: isSelected)
                .foregroundStyle(isSelected ? AppTheme.primaryColor : .gray)
                .imageScale(.large)
                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
            
        case .trades:
            Image(systemName: "arrow.up.right.circle")
                .symbolEffect(.bounce, value: isSelected)
                .foregroundStyle(isSelected ? AppTheme.primaryColor : .gray)
                .imageScale(.large)
                .font(.system(size: 20, weight: isSelected ? .bold : .regular))
        }
    }
} 