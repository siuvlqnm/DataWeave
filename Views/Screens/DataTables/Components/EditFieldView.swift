import SwiftUI
import SwiftData

struct EditFieldView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    let field: DataField
    
    @State private var fieldName: String
    @State private var isRequired: Bool
    @State private var defaultValue: String
    @State private var showDeleteAlert = false
    @State private var showInList = true
    @State private var hideIfEmpty = false
    @State private var showCaption = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable, field: DataField) {
        self.table = table
        self.field = field
        _fieldName = State(initialValue: field.name)
        _isRequired = State(initialValue: field.isRequired)
        _showInList = State(initialValue: field.showInList)
        _defaultValue = State(initialValue: field.defaultValue ?? "")
    }
    
    private var hasRecordsWithValues: Bool {
        table.records.contains { record in
            record.getValue(for: field).isEmpty == false
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("字段名称", text: $fieldName)
                }
                
                Section("可见性") {
                    Toggle("在列表中显示", isOn: $showInList)
                        .tint(accentColor)
                    Toggle("为空时隐藏", isOn: $hideIfEmpty)
                        .tint(accentColor)
                }
                
                Section("详细信息") {
                    Toggle("必填字段", isOn: $isRequired)
                        .tint(accentColor)
                    if field.type != .boolean && field.type != .image && field.type != .file {
                        TextField("默认值", text: $defaultValue)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        Text("删除字段")
                    }
                    .disabled(hasRecordsWithValues)
                }
            }
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            .navigationTitle("编辑字段")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        updateField()
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
            .alert("删除字段", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) {}
                Button("删除", role: .destructive) {
                    deleteField()
                }
            } message: {
                Text("确定要删除这个字段吗？此操作无法撤销。")
            }
        }
    }
    
    private func updateField() {
        field.name = fieldName
        field.isRequired = isRequired
        field.defaultValue = defaultValue.isEmpty ? nil : defaultValue
        field.showInList = showInList
        try? modelContext.save()
        dismiss()
    }
    
    private func deleteField() {
        if let index = table.fields.firstIndex(where: { $0.id == field.id }) {
            table.fields.remove(at: index)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataTable.self, configurations: config)
    
    let table = DataTable(name: "测试表")
    let field = DataField(name: "测试字段", type: .text)
    table.fields.append(field)
    
    return EditFieldView(table: table, field: field)
        .modelContainer(container)
} 