import SwiftUI

struct CustomTradingIcon: View {
    let icon: TradingIcon
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size * 1.5, height: size * 1.5)
            
            Group {
                switch icon {
                case .bestDay, .worstDay, .dashboard, .journal, .trades, .riskReward:
                    Image(systemName: icon.systemName)
                case .winRate:
                    Text("%")
                }
            }
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
} 