import Foundation
import SwiftData

@Model
class Trade {
    var symbol: String
    var entryPrice: Double
    var exitPrice: Double
    var size: Double
    var entryTime: Date
    var exitTime: Date
    var fees: Double
    var isShort: Bool
    var profit: Double
    var notes: String
    var dashboard: Dashboard?
    
    var date: Date { exitTime }
    var profitLoss: Double { profit }
    
    init(symbol: String, entryPrice: Double, exitPrice: Double, size: Double, entryTime: Date, exitTime: Date, fees: Double, isShort: Bool, profit: Double) {
        self.symbol = symbol
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.size = size
        self.entryTime = entryTime
        self.exitTime = exitTime
        self.fees = fees
        self.isShort = isShort
        self.profit = profit
        self.notes = ""
    }
} 