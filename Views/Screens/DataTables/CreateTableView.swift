import SwiftUI
import SwiftData

struct CreateTableView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tableName = ""
    @State private var tableDescription = ""
    @State private var showAddField = false
    @State private var fields: [DataField] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("数据表名称", text: $tableName)
                    TextField("描述（选填）", text: $tableDescription)
                }
                
                Section(header: Text("字段")) {
                    ForEach(fields, id: \.id) { field in
                        HStack {
                            Image(systemName: field.type.icon)
                                .foregroundColor(.blue)
                            Text(field.name)
                            Spacer()
                            Text(field.type.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteField)
                    
                    Button(action: { showAddField = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加字段")
                        }
                    }
                }
            }
            .navigationTitle("新建数据表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        createTable()
                    }
                    .disabled(tableName.isEmpty || fields.isEmpty)
                }
            }
            .sheet(isPresented: $showAddField) {
                AddFieldView(fields: $fields)
            }
        }
    }
    
    private func deleteField(at offsets: IndexSet) {
        fields.remove(atOffsets: offsets)
    }
    
    private func createTable() {
        let table = DataTable(name: tableName, description: tableDescription)
        table.fields = fields
        modelContext.insert(table)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CreateTableView()
} 