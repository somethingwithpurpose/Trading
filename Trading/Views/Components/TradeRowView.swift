import SwiftUI

struct TradeRowView: View {
    let trade: Trade
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trade.symbol)
                    .font(.headline)
                Spacer()
                Text(profitText)
                    .foregroundColor(trade.profit >= 0 ? .green : .red)
            }
            
            HStack {
                Text(trade.isShort ? "Short" : "Long")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(timeText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var profitText: String {
        String(format: "$%.2f", trade.profit)
    }
    
    private var timeText: String {
        trade.entryTime.formatted(date: .abbreviated, time: .shortened)
    }
} 