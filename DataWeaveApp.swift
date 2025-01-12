//
//  DataWeaveApp.swift
//  DataWeave
//
//  Created by Meat on 2025/1/8.
//

import SwiftUI
import SwiftData

@main
struct DataWeaveApp: App {
    let container: ModelContainer = {
        let schema = Schema([DataTable.self, DataRecord.self, DataField.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: modelConfiguration)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
