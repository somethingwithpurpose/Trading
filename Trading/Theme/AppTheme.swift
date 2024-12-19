import SwiftUI
import Foundation

struct AppTheme {
    // Core Brand Colors
    static let accent = Color(red: 0.27, green: 0.84, blue: 0.46)  // Bright neon green
    static let accentDark = Color(red: 0.15, green: 0.45, blue: 0.25)  // Darker green for depth
    static let secondary = Color(red: 0.1, green: 0.1, blue: 0.11)  // Near black
    static let primaryColor = accent  // Added primaryColor
    
    // Background System
    static let backgroundColor = Color.black
    static let cardBackground = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let cardBackgroundSecondary = Color(red: 0.12, green: 0.12, blue: 0.13)  // Added cardBackgroundSecondary
    static let cardBackgroundElevated = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let cardBorder = accent.opacity(0.15)
    
    // Status Colors
    static let successColor = accent
    static let errorColor = Color(red: 0.92, green: 0.25, blue: 0.25)
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.72)
    static let textMuted = Color(red: 0.45, green: 0.45, blue: 0.47)
    
    // UI Constants
    static let cornerRadius: CGFloat = 16
    static let spacing: CGFloat = 16
    static let iconSize: CGFloat = 20
    static let dropShadow = Color.black.opacity(0.35)
    
    // Fonts
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let titleFont = Font.system(size: 24, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .medium, design: .rounded)
    static let monoFont = Font.system(size: 28, weight: .medium, design: .monospaced)
    
    // Gradients
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                backgroundColor,
                Color(red: 0.06, green: 0.08, blue: 0.09),
                backgroundColor
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var glassEffect: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .opacity(0.7)
    }
    
    static var glowingBackground: some View {
        ZStack {
            Color.black
            
            // Corner glows
            ForEach(0..<4) { corner in
                Circle()
                    .fill(accent)
                    .frame(width: 300, height: 300)
                    .blur(radius: 150)
                    .opacity(0.1)
                    .offset(
                        x: corner < 2 ? -200 : 200,
                        y: corner % 2 == 0 ? -200 : 200
                    )
            }
            
            // Center ambient glow
            Circle()
                .fill(accent)
                .frame(width: 400, height: 400)
                .blur(radius: 200)
                .opacity(0.05)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Components
extension AppTheme {
    struct StatBox: View {
        let title: String
        let value: String
        let icon: TradingIcon
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon.systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.cardBackground,
                                    AppTheme.cardBackground.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                        .fill(color.opacity(0.03))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 