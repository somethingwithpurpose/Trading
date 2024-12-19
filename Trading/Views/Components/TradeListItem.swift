import SwiftUI
import SwiftData

struct TradeListItem: View {
    let trade: Trade
    @State private var appear = false
    @Binding var selectedDetailDate: Date?
    
    var body: some View {
        Button {
            selectedDetailDate = trade.exitTime
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trade.exitTime.formatted(.dateTime.month().day()))
                        .font(.system(size: 17, weight: .medium))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundStyle(.linearGradient(
                                colors: [.gray, .gray.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        Text(trade.symbol)
                            .foregroundColor(.gray)
                        Text("\(trade.size, specifier: "%.2f") shares")
                            .foregroundColor(.gray)
                    }
                    .font(.system(size: 14))
                }
                
                Spacer()
                
                Text(trade.profit >= 0 ? "+$\(String(format: "%.2f", trade.profit))" : "-$\(String(format: "%.2f", abs(trade.profit)))")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(trade.profit >= 0 ? .green : .red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6).opacity(0.1))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            .offset(y: appear ? 0 : 20)
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appear = true
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trade.self, configurations: config)
        let trade = Trade(
            symbol: "AAPL",
            entryPrice: 150,
            exitPrice: 160,
            size: 100,
            entryTime: Date(),
            exitTime: Date(),
            fees: 0,
            isShort: false,
            profit: 1000
        )
        
        return TradeListItem(trade: trade, selectedDetailDate: .constant(nil))
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview")
    }
} 