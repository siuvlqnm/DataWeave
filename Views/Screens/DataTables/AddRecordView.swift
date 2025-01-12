import SwiftUI
import SwiftData

struct AddRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let table: DataTable
    @State private var fieldValues: [UUID: String] = [:]
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable) {
        self.table = table
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(table.fields) { field in
                            VStack(alignment: .leading, spacing: 8) {
                                // 字段标题
                                HStack {
                                    Image(systemName: field.type.icon)
                                        .foregroundColor(accentColor)
                                    Text(field.name)
                                        .font(.system(size: 14, weight: .medium))
                                    if field.isRequired {
                                        Text("*")
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                // 根据字段类型显示不同的输入控件
                                FieldInputView(
                                    type: field.type,
                                    value: Binding(
                                        get: { fieldValues[field.id] ?? "" },
                                        set: { fieldValues[field.id] = $0 }
                                    )
                                )
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("添加记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(mainColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                    }
                    .disabled(!isValidRecord)
                    .foregroundColor(isValidRecord ? accentColor : .gray)
                }
            }
        }
    }
    
    private var isValidRecord: Bool {
        // 检查所有必填字段是否都有值
        for field in table.fields where field.isRequired {
            if fieldValues[field.id]?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    private func saveRecord() {
        // 创建新记录
        let record = DataRecord(table: table)
        
        // 保存所有字段值
        for field in table.fields {
            if let value = fieldValues[field.id] {
                record.setValue(value, for: field)
            }
        }
        
        modelContext.insert(record)
        try? modelContext.save()
        dismiss()
    }
}

// 字段输入控件
struct FieldInputView: View {
    let type: DataField.FieldType
    @Binding var value: String
    
    var body: some View {
        switch type {
        case .text:
            TextField("请输入文本", text: $value)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
        case .richText:
            TextEditor(text: $value)
                .frame(height: 100)
                .padding(4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
        case .number:
            TextField("请输入数字", text: $value)
                .textFieldStyle(.plain)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
        case .boolean:
            Toggle(isOn: Binding(
                get: { value == "true" },
                set: { value = $0 ? "true" : "false" }
            )) {
                Text("布尔")
            }
            
        // TODO: 实现其他类型的输入控件
        default:
            TextField("请输入", text: $value)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

#Preview {
    let table = DataTable(name: "测试表")
    table.fields = [
        DataField(name: "姓名", type: .text, isRequired: true),
        DataField(name: "年龄", type: .number),
        DataField(name: "简介", type: .richText),
        DataField(name: "是否学生", type: .boolean)
    ]
    return AddRecordView(table: table)
} 
