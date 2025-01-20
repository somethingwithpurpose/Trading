import SwiftUI

struct LoadingView: View {
    @State private var showLogo = false
    @State private var showText = false
    @State private var gridOffset: CGFloat = -1000
    @State private var backgroundOpacity: Double = 0
    @State private var backgroundScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            
            // Animated background circles
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "6C63FF").opacity(0.1),
                                    Color(hex: "4C46B6").opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300 + CGFloat(i * 100), height: 300 + CGFloat(i * 100))
                        .offset(x: CGFloat.random(in: -50...50),
                               y: CGFloat.random(in: -50...50))
                        .opacity(backgroundOpacity)
                        .scaleEffect(backgroundScale)
                        .blur(radius: 50)
                }
            }
            
            // Animated grid background
            GridBackground()
                .offset(x: gridOffset)
                .opacity(0.1)
            
            // Main content
            VStack(spacing: 40) {
                // Animated logo
                MaxxLogo(size: 180)
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : 20)
                    .scaleEffect(showLogo ? 1 : 0.8)
                
                // Logo text
                LogoText(size: 28)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
            }
        }
        .onAppear {
            // Animate background
            withAnimation(.easeOut(duration: 1.2)) {
                backgroundOpacity = 1
                backgroundScale = 1
            }
            
            // Animate grid
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                gridOffset = 0
            }
            
            // Animate logo
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                showLogo = true
            }
            
            // Animate text
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.6)) {
                showText = true
            }
        }
    }
}

struct LogoView: View {
    var rotation: Double
    var scale: CGFloat
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "6C63FF"),
                            Color(hex: "4C46B6")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(rotation))
            
            // Inner design
            VStack(spacing: 5) {
                Text("M")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "6C63FF"))
                
                Text("MAXX")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "4C46B6"))
            }
        }
        .scaleEffect(scale)
    }
}

struct LoadingIndicator: View {
    var isAnimating: Bool
    @State private var indicatorRotation = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                LoadingDot(index: index, isAnimating: isAnimating)
            }
        }
        .frame(width: 50, height: 50)
    }
}

struct LoadingDot: View {
    let index: Int
    var isAnimating: Bool
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(Color(hex: "6C63FF").opacity(0.3))
            .frame(width: 8, height: 8)
            .offset(y: -20)
            .rotationEffect(.degrees(Double(index) * 45))
            .scaleEffect(scale)
            .onAppear {
                let delay = Double(index) * 0.1
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(delay)
                ) {
                    scale = 1
                }
            }
    }
}

struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 40
                let rows = Int(geometry.size.height / spacing) + 1
                let columns = Int(geometry.size.width / spacing) + 1
                
                // Vertical lines
                for column in 0...columns {
                    let x = CGFloat(column) * spacing
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                }
                
                // Horizontal lines
                for row in 0...rows {
                    let y = CGFloat(row) * spacing
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "6C63FF").opacity(0.3),
                        Color(hex: "4C46B6").opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.5
            )
        }
    }
}
