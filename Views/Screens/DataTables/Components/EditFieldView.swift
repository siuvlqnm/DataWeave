import SwiftUI
import SwiftData

struct EditFieldView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    let field: DataField
    
    @State private var fieldName: String
    @State private var fieldType: DataField.FieldType
    @State private var isRequired: Bool
    @State private var defaultValue: String
    @State private var showProFeatureAlert = false
    @State private var showDeleteAlert = false
    
    init(table: DataTable, field: DataField) {
        self.table = table
        self.field = field
        _fieldName = State(initialValue: field.name)
        _fieldType = State(initialValue: field.type)
        _isRequired = State(initialValue: field.isRequired)
        _defaultValue = State(initialValue: field.defaultValue ?? "")
    }
    
    private var isProType: Bool {
        fieldType.isPro
    }
    
    private var hasRecordsWithValues: Bool {
        table.records.contains { record in
            record.getValue(for: field).isEmpty == false
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("字段名称", text: $fieldName)
                    
                    Picker("字段类型", selection: $fieldType) {
                        ForEach(DataField.FieldType.allCases, id: \.self) { type in
                            Label {
                                Text(type.rawValue)
                            } icon: {
                                Image(systemName: type.icon)
                            }
                            .tag(type)
                        }
                    }
                    .disabled(hasRecordsWithValues) // 如果已有数据，禁止修改类型
                }
                
                Section("字段设置") {
                    Toggle("必填字段", isOn: $isRequired)
                    
                    TextField("默认值", text: $defaultValue)
                }
                
                Section {
                    Button(role: .destructive, action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("删除字段")
                        }
                    }
                    .disabled(hasRecordsWithValues) // 如果已有数据，禁止删除
                }
            }
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
                        if isProType && field.type != fieldType {
                            showProFeatureAlert = true
                        } else {
                            updateField()
                        }
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
            .alert("Pro 功能", isPresented: $showProFeatureAlert) {
                Button("确定") {}
            } message: {
                Text("该字段类型需要升级到 Pro 版本才能使用")
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
        field.type = fieldType
        field.isRequired = isRequired
        field.defaultValue = defaultValue.isEmpty ? nil : defaultValue
        
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