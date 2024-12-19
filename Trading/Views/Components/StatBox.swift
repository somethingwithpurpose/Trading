import SwiftUI

struct StatBox: View {
    let title: String
    let value: String
    let icon: TradingIcon
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                Spacer()
                
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
    }
    
    private var iconName: String {
        switch icon {
        case .bestDay: return "arrow.up.right.circle.fill"
        case .worstDay: return "arrow.down.right.circle.fill"
        case .winRate: return "chart.pie.fill"
        case .riskReward: return "arrow.left.arrow.right.circle.fill"
        case .dashboard: return "square.grid.2x2.fill"
        case .journal: return "book.fill"
        case .trades: return "list.bullet.rectangle.fill"
        }
    }
}