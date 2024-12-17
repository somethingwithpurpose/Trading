import Foundation
import SwiftData

@Model
final class Trade {
    var symbol: String
    var entryPrice: Double
    var exitPrice: Double
    var size: Double
    var entryTime: Date
    var exitTime: Date
    var fees: Double
    var isShort: Bool
    var profit: Double
    var notes: String?
    var journalEntry: String?
    var dashboard: Dashboard?
    
    init(symbol: String = "",
         entryPrice: Double = 0.0,
         exitPrice: Double = 0.0,
         size: Double = 0.0,
         entryTime: Date = Date(),
         exitTime: Date = Date(),
         fees: Double = 0.0,
         isShort: Bool = false,
         profit: Double = 0.0,
         notes: String? = nil,
         journalEntry: String? = nil,
         dashboard: Dashboard? = nil) {
        self.symbol = symbol
        self.entryPrice = entryPrice
        self.exitPrice = exitPrice
        self.size = size
        self.entryTime = entryTime
        self.exitTime = exitTime
        self.fees = fees
        self.isShort = isShort
        self.profit = profit
        self.notes = notes
        self.journalEntry = journalEntry
        self.dashboard = dashboard
    }
}
