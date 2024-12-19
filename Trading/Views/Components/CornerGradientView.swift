import SwiftUI

struct CornerGradientView: View {
    var body: some View {
        ZStack {
            // Top left corner
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.3),
                            Color.green.opacity(0.0)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: 0, y: 0)
                .blur(radius: 60)
            
            // Bottom right corner
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.2),
                            Color.green.opacity(0.0)
                        ]),
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
} 
