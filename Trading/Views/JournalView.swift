import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trades: [Trade]
    @State private var selectedDate = Date()
    @State private var showingAddTrade = false
    
    private var selectedDayTrades: [Trade] {
        let calendar = Calendar.current
        return trades.filter { trade in
            calendar.isDate(trade.exitTime, inSameDayAs: selectedDate)
        }.sorted { $0.exitTime > $1.exitTime }
    }
    
    private var dailyProfit: Double {
        selectedDayTrades.reduce(0) { $0 + $1.profit }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Calendar View
                        CalendarView(trades: trades, selectedDate: $selectedDate)
                            .padding(.horizontal)
                        
                        // Selected Day Stats
                        if !selectedDayTrades.isEmpty {
                            VStack(spacing: 16) {
                                HStack {
                                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "$%.2f", dailyProfit))
                                        .font(.headline)
                                        .foregroundColor(dailyProfit >= 0 ? .green : .red)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                // Daily Trade List
                                ForEach(selectedDayTrades) { trade in
                                    TradeRowView(trade: trade)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(Color(UIColor.systemGray6).opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 16) {
                                Text("No trades on this day")
                                    .font(.system(size: 17))
                                    .foregroundColor(.gray)
                                
                                Button {
                                    showingAddTrade = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .imageScale(.large)
                                        Text("Add Trade")
                                            .font(.system(size: 17))
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Trading Journal")
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView()
            }
        }
    }
} 