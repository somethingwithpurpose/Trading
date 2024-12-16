//
//  TradingApp.swift
//  Trading
//
//  Created by Cale Lane on 12/16/24.
//

import SwiftUI
import SwiftData

@main
struct TradingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Trade.self,
            Dashboard.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoadingView()
        }
        .modelContainer(sharedModelContainer)
    }
}
