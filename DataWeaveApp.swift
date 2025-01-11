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
        let schema = Schema([DataTable.self])
        let container = try! ModelContainer(for: schema)
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
