import SwiftUI
import SwiftData

struct TradesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTrade = false
    @Query private var trades: [Trade]
    @State private var showingDeleteAlert = false
    @State private var tradeToDelete: Trade?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(trades) { trade in
                    TradeRowView(trade: trade)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                tradeToDelete = trade
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteTrades)
            }
            .navigationTitle("Trades")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTrade.toggle() }) {
                        Label("Add Trade", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView()
            }
            .alert("Delete Trade", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let trade = tradeToDelete {
                        deleteTrade(trade)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this trade? This action cannot be undone.")
            }
        }
    }
    
    private func deleteTrade(_ trade: Trade) {
        withAnimation {
            modelContext.delete(trade)
            try? modelContext.save()
        }
    }
    
    private func deleteTrades(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(trades[index])
            }
            try? modelContext.save()
        }
    }
} 