import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trades: [Trade]
    @State private var showingAddTrade = false
    @State private var showingCSVImport = false
    @State private var animateChart = false
    @State private var selectedDashboard: Dashboard?
    
    // Computed Properties
    private var totalProfit: String {
        let total = trades.reduce(0) { $0 + $1.profit }
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
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profit Chart
                        ChartCard {
                            Chart(trades) { trade in
                                LineMark(
                                    x: .value("Date", trade.exitTime),
                                    y: .value("Profit", trade.profit)
                                )
                                .foregroundStyle(AppTheme.primaryColor)
                                .opacity(animateChart ? 1 : 0)
                            }
                        }
                        .frame(height: 220)
                        
                        // Total Profit
                        HStack {
                            Text("Total Profit")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("$\(totalProfit)")
                                .foregroundColor(Double(totalProfit) ?? 0 >= 0 ? AppTheme.successColor : AppTheme.errorColor)
                                .font(.title2.bold())
                        }
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatBox(title: "Best Day", value: "$\(bestDay)", icon: "chart.line.uptrend.xyaxis", color: AppTheme.successColor)
                            StatBox(title: "Worst Day", value: "$\(worstDay)", icon: "chart.line.downtrend.xyaxis", color: AppTheme.errorColor)
                            StatBox(title: "Win Rate", value: "\(winRate)%", icon: "percent", color: AppTheme.primaryColor)
                            StatBox(title: "R:R", value: String(format: "%.1f", riskRewardRatio), icon: "arrow.left.arrow.right", color: AppTheme.primaryColor)
                        }
                        
                        // Progress Bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profit Goal")
                                .foregroundColor(.gray)
                            ProgressView(value: max(0, min(Double(totalProfit) ?? 0, 3000)), total: 3000)
                                .tint(AppTheme.primaryColor)
                            Text("\(totalProfit)/3000")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 16) {
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
                        }
                    }
                    .padding()
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
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)) {
                    animateChart = true
                }
            }
        }
    }
} 
