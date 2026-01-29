//
//  luna_mvp_demo_v4App.swift
//  luna-mvp-demo-v4
//
//  Created by John Moeller on 1/16/26.
//

import SwiftUI
import SwiftData

@main
struct luna_mvp_demo_v4App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
