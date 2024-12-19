import SwiftUI

struct CustomIcon: View {
    let systemName: String
    let color: Color
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .onAppear {
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.6)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 20) {
            CustomIcon(systemName: "chart.xyaxis.line", color: .blue, size: 24)
            CustomIcon(systemName: "plus.circle.fill", color: .green, size: 24)
            CustomIcon(systemName: "arrow.up.right.circle", color: .orange, size: 24)
        }
    }
} 