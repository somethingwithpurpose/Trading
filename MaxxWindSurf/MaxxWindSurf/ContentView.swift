import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserManager.shared
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                NavigationView {
                    if userManager.isAuthenticated {
                        HomeView()
                            .navigationBarHidden(true)
                    } else {
                        LoginView()
                            .navigationBarHidden(true)
                    }
                }
            }
        }
    }
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showSignUp = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            // Background grid
            GridBackground()
                .opacity(0.05)
            
            ScrollView {
                VStack(spacing: 48) {
                    // Creative header
                    VStack(spacing: 24) {
                        // Logo
                        LogoView(rotation: 45, scale: 1)
                        
                        // Tagline
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "4C46B6"))
                            
                            Text("Your journey to transformation begins here")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .offset(y: viewModel.headerOffset)
                    
                    // Login form
                    VStack(spacing: 32) {
                        // Email field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(focusedField == .email ? Color(hex: "6C63FF") : .gray)
                                    .font(.system(size: 20))
                                
                                TextField("", text: $viewModel.email)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .placeholder(when: viewModel.email.isEmpty) {
                                        Text("Enter your email")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                            }
                            .padding()
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05),
                                           radius: 15, x: 0, y: 5)
                            )
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(focusedField == .password ? Color(hex: "6C63FF") : .gray)
                                    .font(.system(size: 20))
                                
                                SecureField("", text: $viewModel.password)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .placeholder(when: viewModel.password.isEmpty) {
                                        Text("Enter your password")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                            }
                            .padding()
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05),
                                           radius: 15, x: 0, y: 5)
                            )
                        }
                        
                        // Login button
                        Button(action: {
                            Task {
                                await viewModel.login()
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                        }
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
                        .disabled(viewModel.isLoading)
                        
                        // Sign Up button
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Don't have an account? Sign Up")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Color(hex: "6C63FF"))
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(viewModel.contentOpacity)
                }
                .padding(.vertical, 48)
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                viewModel.headerOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                viewModel.contentOpacity = 1
            }
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var headerOffset: CGFloat = -200
    @Published var contentOpacity: Double = 0
    
    func login() async {
        isLoading = true
        
        do {
            _ = try await UserManager.shared.signIn(
                email: email,
                password: password
            )
        } catch {
            showError(message: error.localizedDescription)
        }
        
        isLoading = false
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GridBackground: View {
    var body: some View {
        VStack {
            ForEach(0..<10) { row in
                HStack {
                    ForEach(0..<10) { col in
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat(row % 2) * 10)
                    }
                }
            }
        }
        .rotationEffect(.degrees(45))
    }
}

struct MaxxLogo: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "6C63FF").opacity(0.1))
                .frame(width: size, height: size)
            
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
            
            VStack(spacing: 8) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size / 2))
                    path.addLine(to: CGPoint(x: size / 4, y: 0))
                    path.addLine(to: CGPoint(x: size / 2, y: size / 2))
                    path.addLine(to: CGPoint(x: size * 3 / 4, y: 0))
                    path.addLine(to: CGPoint(x: size, y: size / 2))
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "6C63FF"),
                            Color(hex: "4C46B6")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                )
                .frame(width: size / 2, height: size / 2)
                
                Text("MAXX")
                    .font(.system(size: size / 6, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "4C46B6"))
            }
        }
    }
}

struct LogoView: View {
    let rotation: Double
    let scale: CGFloat
    
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 50))
            .foregroundColor(.black)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(2)
        }
    }
}
