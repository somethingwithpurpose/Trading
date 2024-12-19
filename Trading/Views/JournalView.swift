import SwiftUI
import SwiftData

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
    @Query(sort: \Trade.exitTime, order: .reverse) private var trades: [Trade]
    @State private var showingAddTrade = false
    @State private var showingDeleteAlert = false
    @State private var tradeToDelete: Trade?
    @State private var selectedDate: Date = Date()
    @State private var selectedDetailDate: Date? = nil
    @Binding var selectedDashboard: Dashboard?
    
    init(selectedDashboard: Binding<Dashboard?>) {
        self._selectedDashboard = selectedDashboard
        self._trades = Query()
    }
    
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
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: 8), count: 7), spacing: 8) {
                            // Calendar days
                            ForEach(weeks.flatMap { $0 }, id: \.self) { date in
                                if let date = date {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedDate = date
                                            selectedDetailDate = date
                                        }
                                    } label: {
                                        DayCell(
                                            date: date,
                                            isSelected: calendar.isDate(date, inSameDayAs: selectedDetailDate ?? selectedDate),
                                            profit: dailyProfits[calendar.startOfDay(for: date)] ?? 0
                                        )
                                    }
                                } else {
                                    Color.clear
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Trade List
                    ForEach(filteredTrades) { trade in
                        TradeListItem(trade: trade, selectedDetailDate: $selectedDetailDate)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView(
                    selectedDashboard: $selectedDashboard,
                    showingAddTrade: $showingAddTrade
                )
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
                    .presentationDetents([.large])
                    .presentationBackground(.black)
                    .preferredColorScheme(.dark)
                }
            }
        }
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let profit: Double
    
    var body: some View {
        VStack(spacing: 1) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(profit != 0 ? .white : .gray)
            
            if profit != 0 {
                Text(profit >= 0 ? "+$\(String(format: "%.0f", profit))" : "-$\(String(format: "%.0f", abs(profit)))")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(profit >= 0 ? .green : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: 40, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(profit > 0 ? Color.green.opacity(0.15) : 
                     profit < 0 ? Color.red.opacity(0.15) : 
                     Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : 
                       profit > 0 ? Color.green.opacity(0.3) : 
                       profit < 0 ? Color.red.opacity(0.3) : 
                       Color.clear,
                       lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct DayDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let trades: [Trade]
    @State private var journalText: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    // Date Header with Gradient Background
                    Text(date.formatted(date: .complete, time: .omitted))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .padding(.top, 12)
                    
                    // Trade Summary Card
                    if !trades.isEmpty {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Daily Summary")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text("\(trades.count) \(trades.count == 1 ? "Trade" : "Trades")")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                                Spacer()
                                let totalProfit = trades.reduce(0) { $0 + $1.profit }
                                Text(totalProfit >= 0 ? "+$\(String(format: "%.2f", totalProfit))" : "-$\(String(format: "%.2f", abs(totalProfit)))")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(totalProfit >= 0 ? .green : .red)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            
                            // Individual Trades
                            ForEach(trades) { trade in
                                TradeListItem(trade: trade, selectedDetailDate: .constant(nil))
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // File Upload Box
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Trade Files")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button {
                            showingImagePicker = true
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.7)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upload Trade Files")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Add screenshots or documents")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        if let image = selectedImage {
                            VStack(spacing: 12) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                
                                Button {
                                    selectedImage = nil
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Remove File")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Journal Entry Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Journal Entry")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $journalText)
                            .frame(minHeight: 150)
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveJournalEntries()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                loadExistingData()
            }
        }
    }
    
    private func loadExistingData() {
        if let firstTrade = trades.first {
            journalText = firstTrade.journalEntry ?? ""
            if let imageData = firstTrade.tradeImage,
               let uiImage = UIImage(data: imageData) {
                selectedImage = uiImage
            }
        }
    }
    
    private func saveJournalEntries() {
        for trade in trades {
            trade.journalEntry = journalText
            if let image = selectedImage,
               let imageData = image.jpegData(compressionQuality: 0.7) {
                trade.tradeImage = imageData
            } else {
                trade.tradeImage = nil
            }
        }
        try? modelContext.save()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
