import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    @State private var textOpacity = 0.0
    @State private var textOffset: CGFloat = 20
    @State private var scale = 0.9
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            if isActive {
                MainTabView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                    AnimatedTradeVaultLogo()
                        .scaleEffect(scale)
                    
                    Text("TradeVault")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                    
                    Text("Your Trading Journey, Analyzed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .opacity(textOpacity)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        scale = 1
                    }
                    
                    withAnimation(.easeOut(duration: 0.5).delay(2.0)) {
                        textOpacity = 1
                        textOffset = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
} 