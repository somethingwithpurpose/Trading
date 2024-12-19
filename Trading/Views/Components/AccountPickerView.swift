import SwiftUI
import SwiftData

struct AccountPickerView: View {
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @Query private var dashboards: [Dashboard]
    @State private var showingNewDashboard = false
    
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
            HStack(spacing: 6) {
                Text(selectedDashboard?.name ?? "Account")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
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
