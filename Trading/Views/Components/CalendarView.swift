import SwiftUI

struct CalendarView: View {
    let date: Date
    let dailyProfits: [Date: Double]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        let profit = dailyProfits[calendar.startOfDay(for: date)] ?? 0
                        
                        Button {
                            onDateSelected(date)
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 14, weight: .medium))
                                
                                if profit != 0 {
                                    Circle()
                                        .fill(profit > 0 ? Color.green : Color.red)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(calendar.isDateInToday(date) ? 
                                         AppTheme.accent.opacity(0.2) : 
                                         Color(.systemGray6))
                            )
                        }
                        .foregroundStyle(calendar.isDateInToday(date) ? 
                                       AppTheme.accent : 
                                       Color.primary)
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        // Add remaining nil days to complete the last week
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            days.append(contentsOf: Array(repeating: nil, count: remainingDays))
        }
        
        return days
    }
}
