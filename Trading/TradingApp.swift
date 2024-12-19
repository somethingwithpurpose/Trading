import SwiftUI
import SwiftData

@main
struct TradingApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let schema = Schema([
                Trade.self,
                Dashboard.self
            ])
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingView()
        }
        .modelContainer(container)
    }
}
