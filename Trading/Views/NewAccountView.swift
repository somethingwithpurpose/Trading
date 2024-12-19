import SwiftUI
import SwiftData

struct NewAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var accountName = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Icon Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.primaryColor, AppTheme.primaryColor.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                        
                        Text("Create New Account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    // Account Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Name")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("", text: $accountName)
                            .placeholder(when: accountName.isEmpty) {
                                Text("Enter account name")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createAccount()
                    }
                    .foregroundColor(accountName.isEmpty ? .gray : AppTheme.primaryColor)
                    .disabled(accountName.isEmpty)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private func createAccount() {
        let dashboard = Dashboard(name: accountName)
        modelContext.insert(dashboard)
        dismiss()
    }
}

