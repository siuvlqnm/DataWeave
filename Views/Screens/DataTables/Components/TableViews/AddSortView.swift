import SwiftUI

struct AddSortView: View {
    @Environment(\.dismiss) private var dismiss
    let table: DataTable
    let onAdd: (ViewSortOrder) -> Void
    
    @State private var selectedFieldId: String?  // 改用 String 来存储选中的字段ID
    @State private var ascending = true
    @State private var groupByValue = false
    
    // 系统字段枚举
    enum SystemField: String, CaseIterable {
        case creationDate = "creation_date"
        case modifiedDate = "modified_date"
        
        var name: String {
            switch self {
            case .creationDate: return "创建日期"
            case .modifiedDate: return "修改日期"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // 字段选择部分
                Section("字段") {
                    ForEach(table.fields) { field in
                        HStack {
                            Text(field.name)
                            Spacer()
                            if selectedFieldId == field.id.uuidString {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFieldId = field.id.uuidString
                        }
                    }
                }
                
                // 系统参数部分
                Section("系统参数") {
                    ForEach(SystemField.allCases, id: \.self) { systemField in
                        HStack {
                            Text(systemField.name)
                            Spacer()
                            if selectedFieldId == systemField.rawValue {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFieldId = systemField.rawValue
                        }
                    }
                }
                
                // 排序方向部分
                Section {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.blue)
                        Button("升序") {
                            ascending = true
                        }
                        Spacer()
                        if ascending {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                        Button("降序") {
                            ascending = false
                        }
                        Spacer()
                        if !ascending {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // 按值分组部分
                Section {
                    Toggle("按值分组", isOn: $groupByValue)
                }
            }
            .navigationTitle("排序方式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        if let fieldId = selectedFieldId {
                            let sort = ViewSortOrder(
                                fieldId: fieldId,
                                ascending: ascending,
                                index: 0
                            )
                            onAdd(sort)
                            dismiss()
                        }
                    }
                    .disabled(selectedFieldId == nil)
                }
            }
        }
    }
} 