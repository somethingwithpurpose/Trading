import SwiftUI

struct TimeFramePickerView: View {
    @Binding var selectedTimeFrame: ProfitTimeFrame
    
    var body: some View {
        Menu {
            // Existing timeframe menu content
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
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
} 
