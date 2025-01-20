import SwiftUI

struct AddFilterView: View {
    @Environment(\.dismiss) private var dismiss
    let table: DataTable
    let onAdd: (ViewFilter) -> Void
    
    @State private var selectedField: DataField?
    @State private var selectedOperation: ViewFilter.FilterOperation = .equals
    @State private var filterValue = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("字段", selection: $selectedField) {
                    ForEach(table.fields) { field in
                        Text(field.name).tag(field as DataField?)
                    }
                }
                
                Picker("操作", selection: $selectedOperation) {
                    ForEach(ViewFilter.FilterOperation.allCases, id: \.self) { operation in
                        Text(operation.rawValue).tag(operation)
                    }
                }
                
                TextField("值", text: $filterValue)
            }
            .navigationTitle("添加过滤器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        if let field = selectedField {
                            let filter = ViewFilter(
                                fieldId: field.id.uuidString,
                                operation: selectedOperation,
                                value: filterValue
                            )
                            onAdd(filter)
                            dismiss()
                        }
                    }
                    .disabled(selectedField == nil)
                }
            }
        }
    }
} 