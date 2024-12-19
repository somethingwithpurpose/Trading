//
//  DashboardActionsView.swift
//  Trading
//

import SwiftUI

struct DashboardActionsView: View {
    @Binding var showingAddTrade: Bool
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Button(action: { showingAddTrade = true }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Add Trade")
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.cornerRadius)
        }
        .padding(.horizontal)
    }
}
