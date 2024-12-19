import SwiftUI

enum ProfitTimeFrame: String, CaseIterable {
    case day = "Daily"
    case week = "Weekly"
    case month = "Monthly"
    case year = "Yearly"
    case all = "All Time"
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch self {
        case .day:
            formatter.dateFormat = "HH:mm"
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "MMM d"
        case .year:
            formatter.dateFormat = "MMM"
        case .all:
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: date)
    }
}

struct CustomTabIcon: View {
    let icon: TradingIcon
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.accent.opacity(0.2) : Color.clear)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon.systemName)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                isSelected ? AppTheme.accent : .gray,
                                (isSelected ? AppTheme.accent : .gray).opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
            }
            
            Text(icon.title)
                .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                .foregroundStyle(isSelected ? AppTheme.accent : .gray)
        }
    }
}
