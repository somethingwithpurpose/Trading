import SwiftUI
import SwiftData

struct DashboardPicker: View {
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @State private var showingMenu = false
    @State private var showingNewDashboard = false
    @Query private var dashboards: [Dashboard]
    
    var body: some View {
        Menu {
            ForEach(dashboards) { dashboard in
                Button {
                    withAnimation {
                        selectedDashboard = dashboard
                    }
                } label: {
                    HStack {
                        Text(dashboard.name)
                            .foregroundColor(.white)
                        Spacer()
                        if dashboard == selectedDashboard {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.primaryColor)
                        }
                    }
                }
            }
            
            Divider()
            
            Button {
                showingNewDashboard = true
            } label: {
                Label("New Account", systemImage: "plus.circle")
            }
        } label: {
            HStack(spacing: 8) {
                Text(selectedDashboard?.name ?? "Select Account")
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .imageScale(.small)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6).opacity(0.3))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showingNewDashboard) {
            NewDashboardView { name in
                let newDashboard = Dashboard(name: name)
                modelContext.insert(newDashboard)
                selectedDashboard = newDashboard
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

struct RenameDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    let dashboard: Dashboard
    @State private var name: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .placeholder(when: name.isEmpty) {
                        Text("Account Name").foregroundColor(.gray)
                    }
                    .padding(.top, 20)
            }
            .navigationTitle("Rename Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dashboard.name = name
                        dismiss()
                    }
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
