import SwiftUI

struct AddSortView: View {
    @Environment(\.dismiss) private var dismiss
    let table: DataTable
    let onAdd: (ViewSortOrder) -> Void
    
    @State private var selectedField: DataField?
    @State private var ascending = true
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("字段", selection: $selectedField) {
                    ForEach(table.fields) { field in
                        Text(field.name).tag(field as DataField?)
                    }
                }
                
                Toggle("升序", isOn: $ascending)
            }
            .navigationTitle("添加排序")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        if let field = selectedField {
                            let sort = ViewSortOrder(
                                fieldId: field.id.uuidString,
                                ascending: ascending,
                                index: 0
                            )
                            onAdd(sort)
                            dismiss()
                        }
                    }
                    .disabled(selectedField == nil)
                }
            }
        }
    }
} 