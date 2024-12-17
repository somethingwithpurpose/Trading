import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @Query private var trades: [Trade]
    @State private var selectedTimeFrame: ProfitTimeFrame = .total
    @State private var showingCSVImport = false
    @State private var showingAddTrade = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Main Chart Box
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 16) {
                                Color.clear.frame(height: 12)
                                
                                // Profit Display with Dropdown
                                VStack(alignment: .leading, spacing: 8) {
                                    Menu {
                                        ForEach(ProfitTimeFrame.allCases, id: \.self) { timeFrame in
                                            Button(action: {
                                                withAnimation {
                                                    selectedTimeFrame = timeFrame
                                                }
                                            }) {
                                                HStack {
                                                    Text(timeFrame.rawValue + " Profit")
                                                    if timeFrame == selectedTimeFrame {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(selectedTimeFrame.rawValue + " Profit")
                                                .foregroundColor(.white)
                                                .font(.system(size: 17))
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.white)
                                                .imageScale(.small)
                                        }
                                    }
                                    
                                    Text("$\(calculateProfit())")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(calculateProfit().hasPrefix("-") ? .red : .green)
                                }
                                .padding(.horizontal)
                                
                                // Chart
                                ProfitChartView(trades: trades, selectedTimeFrame: selectedTimeFrame)
                                    .frame(height: 220)
                            }
                        }
                        .background(Color(red: 0.11, green: 0.12, blue: 0.14))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatBox(title: "Best Day", value: "$\(bestDay)", icon: "chart.line.uptrend.xyaxis", color: AppTheme.successColor)
                            StatBox(title: "Worst Day", value: "$\(worstDay)", icon: "chart.line.downtrend.xyaxis", color: AppTheme.errorColor)
                            StatBox(title: "Win Rate", value: "\(winRate)%", icon: "percent", color: AppTheme.primaryColor)
                            StatBox(title: "R:R", value: String(format: "%.1f", riskRewardRatio), icon: "arrow.left.arrow.right", color: AppTheme.primaryColor)
                        }
                        .padding(.horizontal)
                        
                        // Upload CSV Button
                        Button(action: { showingCSVImport = true }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Upload CSV")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.buttonColor)
                            .cornerRadius(AppTheme.cornerRadius)
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    DashboardPicker(selectedDashboard: $selectedDashboard)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    GlowingButton(title: "Add Trade", icon: "plus.circle.fill") {
                        showingAddTrade = true
                    }
                    .scaleEffect(0.8)
                    .padding(.trailing, -8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView()
            }
        }
    }
    
    // Helper functions
    private func calculateProfit() -> String {
        let calendar = Calendar.current
        let filteredTrades = trades.filter { trade in
            switch selectedTimeFrame {
            case .total:
                return true
            case .weekly:
                return calendar.isDate(trade.exitTime, equalTo: Date(), toGranularity: .weekOfYear)
            case .monthly:
                return calendar.isDate(trade.exitTime, equalTo: Date(), toGranularity: .month)
            case .yearly:
                return calendar.isDate(trade.exitTime, equalTo: Date(), toGranularity: .year)
            }
        }
        
        let total = filteredTrades.reduce(0) { $0 + $1.profit }
        return String(format: "%.2f", total)
    }
    
    private var bestDay: String {
        let groupedTrades = Dictionary(grouping: trades) { Calendar.current.startOfDay(for: $0.exitTime) }
        let dailyProfits = groupedTrades.mapValues { trades in
            trades.reduce(0) { $0 + $1.profit }
        }
        return String(format: "%.2f", dailyProfits.values.max() ?? 0)
    }
    
    private var worstDay: String {
        let groupedTrades = Dictionary(grouping: trades) { Calendar.current.startOfDay(for: $0.exitTime) }
        let dailyProfits = groupedTrades.mapValues { trades in
            trades.reduce(0) { $0 + $1.profit }
        }
        return String(format: "%.2f", dailyProfits.values.min() ?? 0)
    }
    
    private var winRate: String {
        let winningTrades = trades.filter { $0.profit > 0 }.count
        let rate = trades.isEmpty ? 0 : (Double(winningTrades) / Double(trades.count)) * 100
        return String(format: "%.1f", rate)
    }
    
    private var riskRewardRatio: Double {
        let winners = trades.filter { $0.profit > 0 }
        let losers = trades.filter { $0.profit < 0 }
        
        let avgWin = winners.map { $0.profit }.reduce(0, +) / Double(max(winners.count, 1))
        let avgLoss = abs(losers.map { $0.profit }.reduce(0, +) / Double(max(losers.count, 1)))
        
        return avgLoss == 0 ? 0 : abs(avgWin / avgLoss)
    }
}
