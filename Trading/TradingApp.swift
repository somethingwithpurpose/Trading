import SwiftUI
import SwiftData

@main
struct TradingApp: App {
    let container: ModelContainer
    @State private var isLoading = true
    
    init() {
        do {
            let schema = Schema([
                Dashboard.self,
                Trade.self
            ])
            let config = ModelConfiguration("Trading", schema: schema)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not configure container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isLoading {
                    LoadingView()
                } else {
                    MainTabView()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        }
        .modelContainer(container)
    }
}
