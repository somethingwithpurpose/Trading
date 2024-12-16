import SwiftUI
import SwiftData

struct DashboardPicker: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dashboards: [Dashboard]
    @State private var showingMenu = false
    @State private var showingNewDashboard = false
    @State private var showingRename = false
    @Binding var selectedDashboard: Dashboard?
    
    var body: some View {
        HStack {
            Button {
                showingMenu.toggle()
            } label: {
                HStack(spacing: 6) {
                    Text(selectedDashboard?.name ?? "Account 1")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(AppTheme.primaryColor)
                }
                .foregroundColor(.white)
            }
            .popover(isPresented: $showingMenu) {
                VStack(alignment: .leading, spacing: 0) {
                    // Account list
                    ForEach(dashboards) { dashboard in
                        Button {
                            selectedDashboard = dashboard
                            showingMenu = false
                        } label: {
                            HStack {
                                Text(dashboard.name)
                                    .foregroundColor(.white)
                                Spacer()
                                if dashboard.id == selectedDashboard?.id {
                                    Circle()
                                        .fill(AppTheme.primaryColor)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            dashboard.id == selectedDashboard?.id ? 
                                AppTheme.cardBackground : Color.clear
                        )
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    // Actions
                    Button {
                        showingNewDashboard = true
                        showingMenu = false
                    } label: {
                        HStack {
                            Text("New Account")
                                .foregroundColor(.white)
                            Spacer()
                            Circle()
                                .stroke(AppTheme.primaryColor, lineWidth: 1.5)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(AppTheme.primaryColor)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if let selected = selectedDashboard {
                        Button {
                            showingRename = true
                            showingMenu = false
                        } label: {
                            HStack {
                                Text("Rename Account")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "pencil")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.vertical, 8)
                .frame(width: 220)
                .background(AppTheme.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .presentationCompactAdaptation(.popover)
            }
        }
        .sheet(isPresented: $showingNewDashboard) {
            NewDashboardView { name in
                let dashboard = Dashboard(name: name)
                modelContext.insert(dashboard)
                selectedDashboard = dashboard
            }
        }
        .sheet(isPresented: $showingRename) {
            if let dashboard = selectedDashboard {
                RenameAccountView(dashboard: dashboard)
            }
        }
    }
}

struct NewDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    let onCreate: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    TextField("", text: $name)
                        .placeholder(when: name.isEmpty) {
                            Text("Account Name").foregroundColor(.gray)
                        }
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.primaryColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name)
                        dismiss()
                    }
                    .foregroundColor(name.isEmpty ? .gray : AppTheme.primaryColor)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct RenameAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let dashboard: Dashboard
    
    init(dashboard: Dashboard) {
        self.dashboard = dashboard
        _name = State(initialValue: dashboard.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    TextField("", text: $name)
                        .placeholder(when: name.isEmpty) {
                            Text("Account Name").foregroundColor(.gray)
                        }
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding()
                        .background(AppTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Rename Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.primaryColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dashboard.name = name
                        dismiss()
                    }
                    .foregroundColor(name.isEmpty ? .gray : AppTheme.primaryColor)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// Helper view modifier for placeholder text
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