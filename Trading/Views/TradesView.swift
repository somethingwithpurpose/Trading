import SwiftUI
import SwiftData

struct TradesView: View {
    @Binding var selectedDashboard: Dashboard?
    @Binding var showingAddTrade: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var trades: [Trade]
    @State private var showingDeleteAlert = false
    @State private var tradeToDelete: Trade?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(trades) { trade in
                    TradeRowView(trade: trade)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                tradeToDelete = trade
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView(
                    selectedDashboard: $selectedDashboard,
                    isPresented: $showingAddTrade
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTrade = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.large)
                    }
                }
            }
            .alert("Delete Trade", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let trade = tradeToDelete {
                        modelContext.delete(trade)
                        tradeToDelete = nil
                    }
                }
            }
        }
    }
}
