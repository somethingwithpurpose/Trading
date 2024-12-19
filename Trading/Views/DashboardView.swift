import SwiftUI
import Charts
import SwiftData

struct DashboardView: View {
    // MARK: - State & Properties
    @State private var showingAddTrade = false
    @State private var selectedTimeFrame: ProfitTimeFrame = .week
    @Binding var selectedDashboard: Dashboard?
    @Environment(\.modelContext) private var modelContext
    @Query private var allTrades: [Trade]
    @State private var logoRotation: Double = 0
    @State private var showingNewDashboard = false
    
    // MARK: - Computed Properties for Stats
    private var trades: [Trade] {
        guard let dashboard = selectedDashboard else { return [] }
        return allTrades.filter { $0.dashboard?.id == dashboard.id }
            .sorted(by: { $0.exitTime > $1.exitTime })
    }
    
    private var bestDay: String {
        let bestProfit = trades.map { $0.profit }.max() ?? 0
        return String(format: "%.2f", abs(bestProfit))
    }
    
    private var worstDay: String {
        let worstProfit = trades.map { $0.profit }.min() ?? 0
        return String(format: "%.2f", abs(worstProfit))
    }
    
    private var winRate: String {
        let winningTrades = trades.filter { $0.profit > 0 }.count
        let totalTrades = trades.count
        return totalTrades > 0 ? String(format: "%.0f", Double(winningTrades) / Double(totalTrades) * 100) : "0"
    }
    
    private var groupedData: [TradePoint] {
        let calendar = Calendar.current
        let now = Date()
        let filteredTrades: [Trade]
        let startDate: Date
        
        switch selectedTimeFrame {
        case .day:
            startDate = calendar.startOfDay(for: now)
            filteredTrades = trades.filter { $0.exitTime >= startDate }
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            filteredTrades = trades.filter { $0.exitTime >= startDate }
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
            filteredTrades = trades.filter { $0.exitTime >= startDate }
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
            filteredTrades = trades.filter { $0.exitTime >= startDate }
        case .all:
            filteredTrades = trades
            startDate = trades.last?.exitTime ?? now
        }
        
        let sortedTrades = filteredTrades.sorted(by: { $0.exitTime < $1.exitTime })
        var points: [TradePoint] = []
        var runningProfit: Double = 0
        
        if let firstTrade = sortedTrades.first {
            points.append(TradePoint(date: firstTrade.exitTime.addingTimeInterval(-86400), profit: 0))
        }
        
        for trade in sortedTrades {
            runningProfit += trade.profit
            points.append(TradePoint(date: trade.exitTime, profit: runningProfit))
        }
        
        if points.isEmpty {
            points.append(TradePoint(date: startDate, profit: 0))
            points.append(TradePoint(date: now, profit: 0))
        } else if points.count == 1 {
            points.append(TradePoint(date: now, profit: runningProfit))
        }
        
        return points
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Background gradient glow
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.15),
                        Color.green.opacity(0.05),
                        Color.black
                    ]),
                    center: .top,
                    startRadius: 0,
                    endRadius: UIScreen.main.bounds.height * 0.5
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar with Account and Add button
                    HStack(spacing: 16) {
                        // Account picker on left
                        AccountPickerView(selectedDashboard: $selectedDashboard)
                            .frame(width: 120)
                        
                        Spacer()
                        
                        // Add button on right
                        Button {
                            showingAddTrade = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                    
                    // Chart section with more spacing
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text(groupedData.last?.profit ?? 0 >= 0 ? 
                                 "+$\(String(format: "%.2f", groupedData.last?.profit ?? 0))" :
                                 "-$\(String(format: "%.2f", abs(groupedData.last?.profit ?? 0)))")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(groupedData.last?.profit ?? 0 >= 0 ? .green : .red)
                            
                            Spacer()
                            
                            TimeFramePickerView(selectedTimeFrame: $selectedTimeFrame)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        // Chart with proper spacing
                        ProfitChartView(trades: trades, selectedTimeFrame: selectedTimeFrame)
                            .frame(height: 200)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Stats Section with more spacing
                    VStack(spacing: 16) {
                        HStack {
                            AppTheme.StatBox(title: "Best Day", value: "$\(bestDay)", icon: .bestDay, color: .green)
                            AppTheme.StatBox(title: "Worst Day", value: "-$\(worstDay)", icon: .worstDay, color: .red)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            AppTheme.StatBox(title: "Win Rate", value: "\(winRate)%", icon: .winRate, color: .green)
                            AppTheme.StatBox(title: "R:R", value: "1.5", icon: .riskReward, color: .green)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Upload CSV Button
                    Button(action: {
                        // CSV upload action
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 20))
                            Text("Upload CSV")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
                .padding(.top, 0)
                .ignoresSafeArea(.all, edges: .top)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                        logoRotation = 360
                    }
                }
            }
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView(
                    selectedDashboard: $selectedDashboard,
                    isPresented: $showingAddTrade
                )
            }
            .sheet(isPresented: $showingNewDashboard) {
                NewDashboardView { name in
                    let dashboard = Dashboard(name: name)
                    modelContext.insert(dashboard)
                    selectedDashboard = dashboard
                }
            }
        }
    }
}
