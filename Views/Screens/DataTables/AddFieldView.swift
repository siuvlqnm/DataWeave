import SwiftUI

struct AddFieldView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fields: [DataField]
    
    @State private var fieldName = ""
    @State private var fieldType: DataField.FieldType = .text
    @State private var isRequired = false
    @State private var defaultValue = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("字段信息")) {
                    TextField("字段名称", text: $fieldName)
                    
                    Picker("字段类型", selection: $fieldType) {
                        ForEach(DataField.FieldType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.isPro ? .gray : .blue)
                                Text(type.rawValue)
                                if type.isPro {
                                    Spacer()
                                    Text("PRO")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            .tag(type)
                        }
                    }
                    
                    Toggle("必填", isOn: $isRequired)
                    
                    if fieldType != .boolean && fieldType != .image && fieldType != .file {
                        TextField("默认值（选填）", text: $defaultValue)
                    }
                }
            }
            .navigationTitle("添加字段")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addField()
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
        }
    }
    
    private func addField() {
        let field = DataField(
            name: fieldName,
            type: fieldType,
            isRequired: isRequired,
            defaultValue: defaultValue.isEmpty ? nil : defaultValue
        )
        fields.append(field)
        dismiss()
    }
}

// 为了支持 Picker，需要让 FieldType 遵循 CaseIterable
// extension DataField.FieldType: CaseIterable {} 
