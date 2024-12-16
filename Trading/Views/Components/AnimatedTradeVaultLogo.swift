import SwiftUI

struct AnimatedTradeVaultLogo: View {
    @State private var ringScales: [CGFloat] = Array(repeating: 0, count: 4)
    @State private var ringOpacities: [CGFloat] = Array(repeating: 0, count: 4)
    @State private var centerScale: CGFloat = 0
    @State private var arrowScale: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var glowOpacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(AppTheme.primaryColor.opacity(0.15))
                .frame(width: 80, height: 80)
                .blur(radius: 12)
                .opacity(glowOpacity)
            
            // Concentric rings
            ForEach(0..<4) { index in
                Circle()
                    .stroke(AppTheme.primaryColor.opacity(0.3), style: StrokeStyle(
                        lineWidth: 1,
                        dash: [index == 0 ? 0 : 2, index == 0 ? 0 : 3]
                    ))
                    .frame(width: CGFloat(70 - index * 15), height: CGFloat(70 - index * 15))
                    .scaleEffect(ringScales[index])
                    .opacity(ringOpacities[index])
            }
            
            // Precision lines
            ForEach(0..<8) { index in
                Rectangle()
                    .fill(AppTheme.primaryColor.opacity(0.5))
                    .frame(width: 1, height: 10)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(ringOpacities[0])
            }
            
            // Center target point
            Circle()
                .fill(AppTheme.successColor)
                .frame(width: 8, height: 8)
                .scaleEffect(centerScale)
                .blur(radius: 2)
            
            Circle()
                .fill(AppTheme.successColor)
                .frame(width: 4, height: 4)
                .scaleEffect(centerScale)
        }
        .frame(width: 100, height: 100)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            // Animate rings
            for index in 0..<4 {
                withAnimation(.easeOut(duration: 0.8).delay(Double(index) * 0.2)) {
                    ringScales[index] = 1
                    ringOpacities[index] = 1
                }
            }
            
            // Animate center
            withAnimation(.spring(duration: 0.6).delay(1.0)) {
                centerScale = 1
            }
            
            // Continuous rotation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Glow animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.2)) {
                glowOpacity = 0.8
            }
        }
    }
} 