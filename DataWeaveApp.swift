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
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
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

// import SwiftUI
// import SwiftData

// @main
// struct DataWeaveApp: App {
//     let container: ModelContainer = {
//         do {
//             let schema = Schema([
//                 DataTable.self,
//                 DataRecord.self
//             ], version: Schema.Version(1, 0, 0))
            
//             let modelConfiguration = ModelConfiguration(
//                 for: schema,
//                 isStoredInMemoryOnly: false,
//                 allowsSave: true
//             )
            
//             return try ModelContainer(for: schema, configurations: [modelConfiguration])
//         } catch {
//             print("Failed to create ModelContainer: \(error.localizedDescription)")
//             let config = ModelConfiguration(isStoredInMemoryOnly: true)
//             return try! ModelContainer(for: DataTable.self, DataRecord.self, configurations: [config])
//         }
//     }()
    
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//         }
//         .modelContainer(container)
//     }
// }

