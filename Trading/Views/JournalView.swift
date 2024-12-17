import SwiftUI
import SwiftData

struct CustomIcon: View {
    let systemName: String
    let color: Color
    let size: CGFloat
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(.linearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct JournalEntryView: View {
    let trade: Trade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trade.exitTime, style: .date)
                    .font(.headline)
                Spacer()
                Text("$\(String(format: "%.2f", trade.profit))")
                    .foregroundColor(trade.profit >= 0 ? .green : .red)
                    .font(.headline)
            }
            
            if let notes = trade.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Label("\(trade.symbol)", systemImage: "chart.line.uptrend.xyaxis")
                Spacer()
                Text("\(String(format: "%.2f", trade.size)) shares")
                    .foregroundColor(.gray)
            }
            .font(.footnote)
        }
        .padding(.vertical, 4)
    }
}

struct JournalView: View {
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trade.exitTime, order: .reverse) private var trades: [Trade]
    @State private var showingAddTrade = false
    @State private var showingDeleteAlert = false
    @State private var tradeToDelete: Trade?
    @State private var selectedDate: Date = Date()
    @State private var selectedDetailDate: Date?
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var filteredTrades: [Trade] {
        trades.filter { trade in
            calendar.isDate(trade.exitTime, equalTo: selectedDate, toGranularity: .month)
        }.sorted(by: { $0.exitTime > $1.exitTime })
    }
    
    private var dailyProfits: [Date: Double] {
        Dictionary(grouping: trades.filter { trade in
            calendar.isDate(trade.exitTime, equalTo: selectedDate, toGranularity: .month)
        }) { trade in
            calendar.startOfDay(for: trade.exitTime)
        }.mapValues { trades in
            trades.reduce(0) { $0 + $1.profit }
        }
    }
    
    private var weeks: [[Date?]] {
        let monthInterval = calendar.dateInterval(of: .month, for: selectedDate)!
        let monthFirstWeek = calendar.component(.weekOfMonth, from: monthInterval.start)
        let monthLastWeek = calendar.component(.weekOfMonth, from: monthInterval.end)
        let numberOfWeeks = monthLastWeek - monthFirstWeek + 1
        
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = Array(repeating: nil, count: 7)
        
        // Get the first day of the month
        let firstDay = calendar.dateInterval(of: .month, for: selectedDate)!.start
        
        // Get the weekday of the first day (0 is Sunday, 1 is Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // Fill in the days before the first day of the month
        for i in 0..<firstWeekday {
            currentWeek[i] = nil
        }
        
        // Iterate through the days of the month
        var currentDate = firstDay
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay)!
        
        while currentDate < nextMonth {
            let weekday = calendar.component(.weekday, from: currentDate) - 1
            
            currentWeek[weekday] = currentDate
            
            // If we're at the end of a week, add the week to our array and start a new week
            if weekday == 6 {
                weeks.append(currentWeek)
                currentWeek = Array(repeating: nil, count: 7)
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Add the last week if it's not complete
        if !currentWeek.allSatisfy({ $0 == nil }) {
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Journal Header
                    Text("Journal")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(.top, 8)
                    
                    // Month Navigation and Add Trade Button
                    HStack {
                        Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        GlowingButton(title: "Add Trade", icon: "plus.circle.fill") {
                            showingAddTrade = true
                        }
                        .scaleEffect(0.8)
                    }
                    .padding(.horizontal)
                    
                    // Calendar
                    VStack(spacing: 12) {
                        // Days of week header
                        HStack {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Calendar grid
                        ForEach(weeks, id: \.self) { week in
                            HStack(spacing: 0) {
                                ForEach(week.indices, id: \.self) { index in
                                    if let date = week[index] {
                                        Button(action: {
                                            selectedDetailDate = date
                                        }) {
                                            DayCell(
                                                date: date,
                                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                                profit: dailyProfits[calendar.startOfDay(for: date)] ?? 0
                                            )
                                        }
                                    } else {
                                        Color.clear
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Trade List
                    ForEach(filteredTrades) { trade in
                        TradeListItem(trade: trade)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView()
            }
            .sheet(isPresented: Binding(
                get: { selectedDetailDate != nil },
                set: { if !$0 { selectedDetailDate = nil } }
            )) {
                if let date = selectedDetailDate {
                    DayDetailView(
                        date: date,
                        trades: trades.filter { calendar.isDate($0.exitTime, inSameDayAs: date) }
                    )
                }
            }
        }
    }
}

struct TradeListItem: View {
    let trade: Trade
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(trade.exitTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 17, weight: .medium))
                
                HStack(spacing: 8) {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.linearGradient(
                            colors: [.gray, .gray.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    Text(trade.symbol)
                        .foregroundColor(.gray)
                    Text("\(trade.size, specifier: "%.2f") shares")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 14))
            }
            
            Spacer()
            
            Text(trade.profit >= 0 ? "+$\(String(format: "%.2f", trade.profit))" : "-$\(String(format: "%.2f", abs(trade.profit)))")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(trade.profit >= 0 ? .green : .red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6).opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .offset(y: appear ? 0 : 20)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let profit: Double
    
    private var backgroundColor: Color {
        if profit > 0 {
            return Color.green.opacity(0.15)
        } else if profit < 0 {
            return Color.red.opacity(0.15)
        }
        return Color.clear
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if profit > 0 {
            return Color.green.opacity(0.3)
        } else if profit < 0 {
            return Color.red.opacity(0.3)
        }
        return Color.clear
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(profit != 0 ? .white : .gray)
            
            if profit != 0 {
                Text(profit >= 0 ? "+$\(String(format: "%.0f", profit))" : "-$\(String(format: "%.0f", abs(profit)))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(profit >= 0 ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let trades: [Trade]
    @State private var journalText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Date Header
                    Text(date.formatted(date: .complete, time: .omitted))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Trades for the day
                    if !trades.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Trades")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ForEach(trades) { trade in
                                TradeListItem(trade: trade)
                            }
                        }
                    }
                    
                    // Journal Entry
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Journal Entry")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $journalText)
                            .frame(minHeight: 200)
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveJournalEntries()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Load existing journal entry if any exists
                if let firstTrade = trades.first {
                    journalText = firstTrade.journalEntry ?? ""
                }
            }
        }
    }
    
    private func saveJournalEntries() {
        // Save the journal entry to all trades for this day
        for trade in trades {
            trade.journalEntry = journalText
        }
        try? modelContext.save()
    }
}
