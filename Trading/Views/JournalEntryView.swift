import SwiftUI
import SwiftData

struct JournalEntryRowView: View {
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
            
            if !trade.notes.isEmpty {
                Text(trade.notes)
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