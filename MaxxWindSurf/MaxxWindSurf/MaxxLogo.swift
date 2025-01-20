import SwiftUI

struct MaxxLogo: View {
    let size: CGFloat
    @State private var animateStroke = false
    @State private var animateRotation = false
    @State private var animateScale = false
    @State private var showRings = false
    @State private var glowOpacity = false
    @State private var particleSystem = ParticleSystem()
    
    var body: some View {
        ZStack {
            // Particle system
            ParticleView(system: particleSystem)
                .opacity(0.3)
            
            // Glowing background
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "6C63FF").opacity(0.2),
                            Color(hex: "6C63FF").opacity(0)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .opacity(glowOpacity ? 0.8 : 0.3)
                .scaleEffect(glowOpacity ? 1.2 : 1)
            
            // Rotating rings
            if showRings {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "6C63FF").opacity(0.8),
                                    Color(hex: "4C46B6").opacity(0.4)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: size + CGFloat(i * 30),
                               height: size + CGFloat(i * 30))
                        .rotationEffect(.degrees(animateRotation ? 360 : 0))
                        .animation(
                            Animation.linear(duration: Double(4 + i))
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.2),
                            value: animateRotation
                        )
                }
            }
            
            // Main logo circle
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
                    lineWidth: 2
                )
                .frame(width: size, height: size)
                .scaleEffect(animateScale ? 1 : 0.9)
            
            // Creative M design
            GeometryReader { geometry in
                let width = geometry.size.width * 0.6
                let height = geometry.size.height * 0.4
                let midX = geometry.size.width / 2
                let midY = geometry.size.height / 2
                
                ZStack {
                    // M shadow
                    Path { path in
                        createMPath(path: &path, midX: midX, midY: midY, width: width, height: height)
                    }
                    .stroke(Color(hex: "6C63FF").opacity(0.3), lineWidth: 6)
                    .blur(radius: 8)
                    .offset(x: 2, y: 2)
                    
                    // Main M
                    Path { path in
                        createMPath(path: &path, midX: midX, midY: midY, width: width, height: height)
                    }
                    .trim(from: 0, to: animateStroke ? 1 : 0)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "6C63FF"),
                                Color(hex: "4C46B6")
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            // Start particle system
            particleSystem.start()
            
            // Animate glow
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = true
            }
            
            // Show rings with spring animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                showRings = true
            }
            
            // Animate scale
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateScale = true
            }
            
            // Animate M stroke
            withAnimation(.easeInOut(duration: 1.5)) {
                animateStroke = true
            }
            
            // Start rotation
            animateRotation = true
        }
    }
    
    private func createMPath(path: inout Path, midX: CGFloat, midY: CGFloat, width: CGFloat, height: CGFloat) {
        // Starting point
        path.move(to: CGPoint(x: midX - width/2, y: midY + height/2))
        
        // First peak
        path.addQuadCurve(
            to: CGPoint(x: midX - width/4, y: midY - height/2),
            control: CGPoint(x: midX - width/3, y: midY - height/4)
        )
        
        // Middle valley
        path.addQuadCurve(
            to: CGPoint(x: midX, y: midY + height/4),
            control: CGPoint(x: midX - width/8, y: midY)
        )
        
        // Second peak
        path.addQuadCurve(
            to: CGPoint(x: midX + width/4, y: midY - height/2),
            control: CGPoint(x: midX + width/8, y: midY - height/3)
        )
        
        // End point
        path.addQuadCurve(
            to: CGPoint(x: midX + width/2, y: midY + height/2),
            control: CGPoint(x: midX + width/3, y: midY - height/4)
        )
    }
}

// Particle system for added visual effect
class ParticleSystem {
    let birthRate: Double = 10
    let lifetime: Double = 2
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var scale: CGFloat
        var opacity: Double
        var birthDate: Date
    }
    
    var particles = Set<Particle>()
    var lastUpdate = Date()
    var isActive = false
    
    func start() {
        isActive = true
    }
    
    func update(date: Date) {
        let elapsed = date.timeIntervalSince(lastUpdate)
        lastUpdate = date
        
        // Add new particles
        if isActive {
            let birthCount = Int(birthRate * elapsed)
            for _ in 0..<birthCount {
                let angle = Double.random(in: 0..<2 * .pi)
                let speed = CGFloat.random(in: 20...60)
                particles.insert(Particle(
                    position: CGPoint(x: 0, y: 0),
                    velocity: CGPoint(
                        x: cos(angle) * speed,
                        y: sin(angle) * speed
                    ),
                    scale: CGFloat.random(in: 0.2...0.6),
                    opacity: Double.random(in: 0.3...0.6),
                    birthDate: date
                ))
            }
        }
        
        // Update existing particles
        particles = Set(particles.compactMap { particle in
            let age = date.timeIntervalSince(particle.birthDate)
            if age > lifetime { return nil }
            
            var updatedParticle = particle
            updatedParticle.position.x += particle.velocity.x * CGFloat(elapsed)
            updatedParticle.position.y += particle.velocity.y * CGFloat(elapsed)
            updatedParticle.opacity = 1 - (age / lifetime)
            return updatedParticle
        })
    }
}

struct ParticleView: View {
    @StateObject var system: ParticleSystem
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                system.update(date: timeline.date)
                
                for particle in system.particles {
                    let xPos = particle.position.x + size.width / 2
                    let yPos = particle.position.y + size.height / 2
                    
                    var contextCopy = context
                    contextCopy.opacity = particle.opacity
                    contextCopy.scaleEffect(x: particle.scale, y: particle.scale)
                    
                    let sparkle = Circle().path(in: CGRect(x: xPos - 2, y: yPos - 2, width: 4, height: 4))
                    contextCopy.stroke(
                        sparkle,
                        with: .color(Color(hex: "6C63FF")),
                        lineWidth: 1
                    )
                }
            }
        }
    }
}

struct LogoText: View {
    let size: CGFloat
    @State private var animateText = false
    
    var body: some View {
        Text("MAXX")
            .font(.system(size: size, weight: .bold, design: .rounded))
            .foregroundStyle(MaxxStyle.primaryGradient)
            .opacity(animateText ? 1 : 0)
            .scaleEffect(animateText ? 1 : 0.8)
            .onAppear {
                withAnimation(MaxxStyle.Animation.spring) {
                    animateText = true
                }
            }
    }
}
