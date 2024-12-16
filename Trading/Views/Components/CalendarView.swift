import SwiftUI

struct CalendarView: View {
    let trades: [Trade]
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var monthTitle: String {
        currentMonth.formatted(.dateTime.month().year())
            .uppercased()
    }
    
    private var dailyProfits: [Date: Double] {
        Dictionary(grouping: trades) { trade in
            calendar.startOfDay(for: trade.exitTime)
        }.mapValues { trades in
            trades.reduce(0) { $0 + $1.profit }
        }
    }
    
    private var weeks: [[Date?]] {
        let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)!
        let monthFirstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let monthLength = calendar.component(.day, from: monthInterval.end.addingTimeInterval(-1))
        
        let weekdayOffset = monthFirstWeekday - 1
        var dates: [Date?] = Array(repeating: nil, count: weekdayOffset)
        
        // Add the days of the month
        for day in 1...monthLength {
            if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                           month: calendar.component(.month, from: currentMonth),
                                                           day: day)) {
                dates.append(date)
            }
        }
        
        // Add padding to complete the last week
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        
        // Split into weeks
        return dates.chunked(into: 7)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Text(monthTitle)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Calendar grid
            VStack(spacing: 8) {
                ForEach(weeks, id: \.self) { week in
                    HStack(spacing: 0) {
                        ForEach(week, id: \.self) { date in
                            if let date = date {
                                let profit = dailyProfits[date] ?? 0
                                DayCell(date: date, profit: profit, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                                    .onTapGesture {
                                        withAnimation {
                                            selectedDate = calendar.startOfDay(for: date)
                                        }
                                    }
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
        .background(Color(UIColor.systemBackground).opacity(0.15))
        .cornerRadius(16)
    }
}

struct DayCell: View {
    let date: Date
    let profit: Double
    let isSelected: Bool
    
    private var day: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }
    
    private var profitText: String {
        String(format: "%.2f", abs(profit))
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        }
        if profit > 0 {
            return Color.green.opacity(0.3)
        } else if profit < 0 {
            return Color.red.opacity(0.3)
        }
        return .clear
    }
    
    private var cellHeight: CGFloat {
        profit != 0 ? 60 : 40
    }
    
    var body: some View {
        VStack(spacing: profit != 0 ? 4 : 0) {
            Text(day)
                .font(.system(size: 17))
                .foregroundColor(isSelected ? .white : .primary)
            
            if profit != 0 {
                Text(profitText)
                    .font(.system(size: 12))
                    .foregroundColor(profit >= 0 ? .green : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cellHeight)
        .background(backgroundColor)
        .cornerRadius(profit != 0 ? 12 : 0)
    }
}

// Helper extension to chunk array into smaller arrays
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
} 