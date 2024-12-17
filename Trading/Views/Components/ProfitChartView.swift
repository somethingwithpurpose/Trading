import SwiftUI
import Charts
import Foundation

enum ProfitTimeFrame: String, CaseIterable {
    case total = "Total"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

struct TradePoint: Identifiable {
    let id = UUID()
    let date: Date
    let profit: Double
}

struct ProfitChartView: View {
    let trades: [Trade]
    let selectedTimeFrame: ProfitTimeFrame
    @State private var animationProgress: Double = 0
    
    private var chartData: [TradePoint] {
        if trades.isEmpty {
            return [
                TradePoint(date: Date(), profit: 0),
                TradePoint(date: Date().addingTimeInterval(86400), profit: 50),
                TradePoint(date: Date().addingTimeInterval(172800), profit: 100),
                TradePoint(date: Date().addingTimeInterval(259200), profit: 150),
                TradePoint(date: Date().addingTimeInterval(345600), profit: 200),
                TradePoint(date: Date().addingTimeInterval(432000), profit: 250),
                TradePoint(date: Date().addingTimeInterval(518400), profit: 300)
            ]
        }
        
        let sortedTrades = trades.sorted(by: { $0.exitTime < $1.exitTime })
        var points: [TradePoint] = []
        var runningProfit: Double = 0
        
        if let firstTrade = sortedTrades.first {
            points.append(TradePoint(date: firstTrade.exitTime.addingTimeInterval(-86400), profit: 0))
        }
        
        for trade in sortedTrades {
            runningProfit += trade.profit
            points.append(TradePoint(date: trade.exitTime, profit: runningProfit))
        }
        
        if points.count == 1 {
            points.append(TradePoint(date: Date(), profit: runningProfit))
        }
        
        return points
    }
    
    private var timeframeProfitIsNegative: Bool {
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
        
        let timeframeProfit = filteredTrades.reduce(0.0) { $0 + $1.profit }
        return timeframeProfit < 0
    }
    
    private var displayData: [TradePoint] {
        chartData.map { point in
            if timeframeProfitIsNegative {
                // Keep red case exactly as it was
                return TradePoint(date: point.date, profit: -point.profit)
            } else {
                // For green, take absolute value to ensure positive direction without flipping
                return TradePoint(date: point.date, profit: abs(point.profit))
            }
        }
    }
    
    var body: some View {
        Chart {
            ForEach(displayData) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Profit", point.profit * animationProgress)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            (timeframeProfitIsNegative ? Color.red : Color.green).opacity(0.4),
                            (timeframeProfitIsNegative ? Color.red : Color.green).opacity(0.25),
                            (timeframeProfitIsNegative ? Color.red : Color.green).opacity(0.1)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Profit", point.profit * animationProgress)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(timeframeProfitIsNegative ? Color.red : Color.green)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animationProgress = 1.0
            }
        }
    }
}
