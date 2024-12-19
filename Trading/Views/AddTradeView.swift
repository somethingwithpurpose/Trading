import SwiftUI
import SwiftData

struct AddTradeView: View {
    @Binding var selectedDashboard: Dashboard?
    @Binding var isPresented: Bool
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var symbol = ""
    @State private var tradeType = TradeType.buy
    @State private var profitLoss = ""
    @State private var tradeDate = Date()
    @State private var showingDatePicker = false
    
    enum TradeType: String, CaseIterable {
        case buy = "Buy"
        case sell = "Sell"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Trade Type Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Trade Type")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                ForEach(TradeType.allCases, id: \.self) { type in
                                    Button {
                                        withAnimation {
                                            tradeType = type
                                        }
                                    } label: {
                                        Text(type.rawValue)
                                            .font(.headline)
                                            .foregroundColor(tradeType == type ? .white : .gray)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(tradeType == type ? 
                                                          (type == .buy ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) :
                                                          Color(UIColor.systemGray6).opacity(0.1))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(tradeType == type ?
                                                                   (type == .buy ? Color.green : Color.red) :
                                                                   Color.gray.opacity(0.3),
                                                                   lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Ticker Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ticker")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .leading) {
                                if symbol.isEmpty {
                                    Text("Enter ticker symbol")
                                        .foregroundColor(.gray)
                                        .padding(.leading)
                                }
                                
                                TextField("", text: $symbol)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Profit/Loss Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Profit/Loss")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("$")
                                    .foregroundColor(.gray)
                                    .padding(.leading)
                                
                                ZStack(alignment: .leading) {
                                    if profitLoss.isEmpty {
                                        Text("Enter P&L")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    TextField("", text: $profitLoss)
                                        .font(.system(size: 17))
                                        .foregroundColor(.white)
                                        .keyboardType(.decimalPad)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Date Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Button {
                                showingDatePicker = true
                            } label: {
                                HStack {
                                    Text(tradeDate.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6).opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Trade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTrade()
                    }
                    .disabled(symbol.isEmpty || profitLoss.isEmpty)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker("Select Date", selection: $tradeDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .preferredColorScheme(.dark)
                        .padding()
                        .navigationBarItems(
                            trailing: Button("Done") {
                                showingDatePicker = false
                            }
                        )
                }
                .presentationDetents([.medium])
                .presentationBackground(.black)
            }
        }
    }
    
    private func saveTrade() {
        guard let profit = Double(profitLoss) else { return }
        
        let newTrade = Trade(
            symbol: symbol.uppercased(),
            entryPrice: 0,
            exitPrice: 0,
            size: 1,
            entryTime: tradeDate,
            exitTime: tradeDate,
            fees: 0,
            isShort: tradeType == .sell,
            profit: profit
        )
        newTrade.dashboard = selectedDashboard
        modelContext.insert(newTrade)
        try? modelContext.save()
        dismiss()
    }
} 