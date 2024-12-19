import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    @State private var iconScale: CGFloat = 0.8
    @State private var textOpacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isActive {
                MainTabView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                    // Icon
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(AppTheme.primaryColor.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .blur(radius: 15)
                            .opacity(glowOpacity)
                        
                        // Main icon
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 70, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.5)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(iconScale)
                    
                    Text("TradeVault")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                        .opacity(textOpacity)
                }
            }
        }
        .onAppear {
            // Single animation sequence
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.1
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.3)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                textOpacity = 1
                glowOpacity = 0.8
            }
            
            // Transition to main view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isActive = true
                }
            }
        }
    }
} 