import SwiftUI

struct GlowingButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.primaryColor)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.primaryColor, lineWidth: 2)
                        .blur(radius: 4)
                        .opacity(isPressed ? 0.8 : 0.4)
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .shadow(color: AppTheme.primaryColor.opacity(0.5), radius: isPressed ? 8 : 15)
        }
    }
} 