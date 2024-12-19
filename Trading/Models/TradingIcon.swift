import SwiftUI

enum TradingIcon {
    // Stats icons
    case bestDay
    case worstDay
    case winRate
    case riskReward
    
    // Tab icons
    case dashboard
    case journal
    case trades
    
    var systemName: String {
        switch self {
        case .bestDay: return "chart.line.uptrend.xyaxis"
        case .worstDay: return "chart.line.downtrend.xyaxis"
        case .winRate: return "percent"
        case .riskReward: return "arrow.left.arrow.right"
        case .dashboard: return "chart.line.uptrend.xyaxis"
        case .journal: return "calendar.badge.clock"
        case .trades: return "list.bullet.rectangle.portrait"
        }
    }
    
    var title: String {
        switch self {
        case .bestDay: return "Best Day"
        case .worstDay: return "Worst Day"
        case .winRate: return "Win Rate"
        case .riskReward: return "Risk/Reward"
        case .dashboard: return "Dashboard"
        case .journal: return "Journal"
        case .trades: return "Trades"
        }
    }
} 