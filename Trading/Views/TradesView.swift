import SwiftUI
import SwiftData

struct TradesView: View {
    @Binding var selectedDashboard: Dashboard?
    @Binding var showingAddTrade: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var trades: [Trade]
    @State private var showingDeleteAlert = false
    @State private var tradeToDelete: Trade?
    
    init(selectedDashboard: Binding<Dashboard?>, showingAddTrade: Binding<Bool>) {
        self._selectedDashboard = selectedDashboard
        self._showingAddTrade = showingAddTrade
        self._trades = Query()
    }
    
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
            .navigationTitle("Trades")
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
            .sheet(isPresented: $showingAddTrade) {
                AddTradeView(
                    selectedDashboard: $selectedDashboard,
                    showingAddTrade: $showingAddTrade
                )
            }
            .alert("Delete Trade", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let trade = tradeToDelete {
                        modelContext.delete(trade)
                        tradeToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete this trade? This action cannot be undone.")
            }
        }
    }
}
