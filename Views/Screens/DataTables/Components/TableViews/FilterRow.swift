import SwiftUI

struct FilterRow: View {
    let filter: ViewFilter
    let table: DataTable
    
    var body: some View {
        HStack {
            if let field = table.fields.first(where: { $0.id.uuidString == filter.fieldId }) {
                Text(field.name)
                Text(filter.operation.rawValue)
                Text(filter.value)
            }
        }
    }
} 