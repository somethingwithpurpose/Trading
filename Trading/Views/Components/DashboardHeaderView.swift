import SwiftUI
import SwiftData

struct DashboardHeaderView: View {
    @Binding var selectedTimeFrame: ProfitTimeFrame
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @Query private var dashboards: [Dashboard]
    @State private var showingNewDashboard = false
    
    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.spacing) {
            // Account Picker (Now smaller and left-aligned)
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
                    Text(selectedDashboard?.name ?? "Select")
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
                                .stroke(Color.green.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            
            Spacer()
            
            // Time Frame Picker
            Menu {
                ForEach(ProfitTimeFrame.allCases, id: \.self) { timeFrame in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTimeFrame = timeFrame
                        }
                    } label: {
                        Text(timeFrame.rawValue)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedTimeFrame.rawValue)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
                        )
                )
            }
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
