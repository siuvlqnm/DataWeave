import SwiftUI

struct SortRow: View {
    let sort: ViewSortOrder
    let table: DataTable
    
    var body: some View {
        HStack {
            if let field = table.fields.first(where: { $0.id.uuidString == sort.fieldId }) {
                Text(field.name)
                Image(systemName: sort.ascending ? "arrow.up" : "arrow.down")
            }
        }
    }
} 