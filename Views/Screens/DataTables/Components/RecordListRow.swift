import SwiftUI

struct RecordListRow: View {
    let record: DataRecord
    let fields: [DataField]
    
    private var visibleFields: [DataField] {
        fields.filter { $0.showInList }.sorted { $0.sortIndex < $1.sortIndex }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("#\(record.id.uuidString.prefix(8) ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(record.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(visibleFields, id: \.id) { field in
                if let value = record.values[field.id] {
                    HStack {
                        Image(systemName: field.type.icon)
                            .foregroundColor(.accentColor)
                        Text(field.name)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(value)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}
