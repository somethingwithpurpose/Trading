import SwiftUI

struct CategoryView: View {
    @State private var showContent = false
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Choose Your Path")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Select a category to begin your transformation")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)
                
                // Categories grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(CategoryType.allCases) { category in
                        CategoryCard(category: category)
                            .offset(y: showContent ? 0 : cardOffset)
                            .opacity(showContent ? 1 : 0)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .background(
            ZStack {
                // Background grid
                GridBackground()
                    .opacity(0.05)
                
                // Gradient circles
                ForEach(0..<3) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "6C63FF").opacity(0.2),
                                    Color(hex: "6C63FF").opacity(0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 300 + CGFloat(i * 100))
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -100...100)
                        )
                        .opacity(0.3)
                }
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct CategoryCard: View {
    let category: CategoryType
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: CategoryDetailView(category: category)) {
            VStack(spacing: 16) {
                // Icon
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "6C63FF"),
                                Color(hex: "4C46B6")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Title
                Text(category.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(category.description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1),
                           radius: isPressed ? 5 : 10,
                           x: 0,
                           y: isPressed ? 2 : 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
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
                    .opacity(0.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.2), value: isPressed)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = false
                    }
                }
            }
        }
    }
}

struct CategoryDetailView: View {
    let category: CategoryType
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: category.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "6C63FF"),
                                    Color(hex: "4C46B6")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(category.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(category.description)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                // Content sections
                VStack(spacing: 24) {
                    ForEach(category.sections) { section in
                        SectionCard(section: section)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 30)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 48)
        }
        .background(
            ZStack {
                Color.white
                
                GridBackground()
                    .opacity(0.05)
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct SectionCard: View {
    let section: CategorySection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(section.content)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            if !section.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(section.tasks) { task in
                        HStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "6C63FF"),
                                            Color(hex: "4C46B6")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(task.title)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 16)
            }
            
            Button("Begin") {
                // Handle begin action
            }
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "6C63FF"),
                        Color(hex: "4C46B6")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "6C63FF").opacity(0.3),
                   radius: 20, x: 0, y: 10)
            .padding(.top, 16)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1),
                       radius: 10, x: 0, y: 5)
        )
    }
}

// Models
enum CategoryType: String, CaseIterable, Identifiable {
    case mindset
    case fitness
    case nutrition
    case productivity
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .mindset: return "Mindset Mastery"
        case .fitness: return "Peak Fitness"
        case .nutrition: return "Optimal Nutrition"
        case .productivity: return "Ultimate Productivity"
        }
    }
    
    var description: String {
        switch self {
        case .mindset: return "Transform your mindset and unlock your full potential"
        case .fitness: return "Achieve your ideal physique and peak performance"
        case .nutrition: return "Fuel your body with optimal nutrition strategies"
        case .productivity: return "Master time management and achieve your goals"
        }
    }
    
    var icon: String {
        switch self {
        case .mindset: return "brain.head.profile"
        case .fitness: return "figure.run"
        case .nutrition: return "leaf.fill"
        case .productivity: return "chart.bar.fill"
        }
    }
    
    var sections: [CategorySection] {
        // Add your sections here
        [
            CategorySection(
                title: "Getting Started",
                content: "Begin your journey with foundational principles",
                tasks: [
                    Task(title: "Complete initial assessment"),
                    Task(title: "Set your goals"),
                    Task(title: "Create your action plan")
                ]
            ),
            CategorySection(
                title: "Core Concepts",
                content: "Master the fundamental concepts and techniques",
                tasks: [
                    Task(title: "Learn key principles"),
                    Task(title: "Practice daily habits"),
                    Task(title: "Track your progress")
                ]
            )
        ]
    }
}

struct CategorySection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let tasks: [Task]
}

struct Task: Identifiable {
    let id = UUID()
    let title: String
}
