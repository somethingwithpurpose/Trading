import SwiftUI

struct MaxxStyle {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "6C63FF"),
            Color(hex: "4C46B6")
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let secondaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "6C63FF").opacity(0.8),
            Color(hex: "4C46B6").opacity(0.4)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glowGradient = RadialGradient(
        gradient: Gradient(colors: [
            Color(hex: "6C63FF").opacity(0.2),
            Color(hex: "6C63FF").opacity(0)
        ]),
        center: .center,
        startRadius: 0,
        endRadius: 100
    )
    
    struct Text {
        static let titleLarge = Font.system(size: 32, weight: .bold, design: .rounded)
        static let titleMedium = Font.system(size: 24, weight: .bold, design: .rounded)
        static let titleSmall = Font.system(size: 20, weight: .bold, design: .rounded)
        static let body = Font.system(size: 16, weight: .medium, design: .rounded)
        static let caption = Font.system(size: 14, weight: .medium, design: .rounded)
        static let button = Font.system(size: 16, weight: .semibold, design: .rounded)
    }
    
    struct Colors {
        static let primary = Color(hex: "6C63FF")
        static let secondary = Color(hex: "4C46B6")
        static let text = Color.black
        static let textSecondary = Color.gray
        static let background = Color.white
        static let backgroundSecondary = Color.gray.opacity(0.05)
    }
    
    struct Layout {
        static let padding: CGFloat = 24
        static let spacing: CGFloat = 16
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 56
    }
    
    struct Animation {
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.7)
        static let easeOut = Animation.easeOut(duration: 0.3)
    }
}

// Custom button style
struct MaxxButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MaxxStyle.Text.button)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: MaxxStyle.Layout.buttonHeight)
            .background(MaxxStyle.primaryGradient)
            .cornerRadius(MaxxStyle.Layout.cornerRadius)
            .shadow(color: MaxxStyle.Colors.primary.opacity(0.3),
                   radius: 20, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Custom text field style
struct MaxxTextFieldStyle: TextFieldStyle {
    @Binding var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
                .font(MaxxStyle.Text.body)
        }
        .padding()
        .frame(height: MaxxStyle.Layout.buttonHeight)
        .background(MaxxStyle.Colors.backgroundSecondary)
        .cornerRadius(MaxxStyle.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: MaxxStyle.Layout.cornerRadius)
                .stroke(
                    isFocused ? MaxxStyle.Colors.primary : Color.gray.opacity(0.1),
                    lineWidth: isFocused ? 2 : 1
                )
        )
    }
}

// Custom card style for category views
struct MaxxCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(MaxxStyle.Layout.padding)
            .background(MaxxStyle.Colors.background)
            .cornerRadius(MaxxStyle.Layout.cornerRadius)
            .shadow(color: Color.black.opacity(0.05),
                   radius: 10, x: 0, y: 5)
    }
}

extension View {
    func maxxCard() -> some View {
        modifier(MaxxCardStyle())
    }
}
