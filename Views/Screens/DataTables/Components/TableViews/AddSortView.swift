import SwiftUI

struct AddSortView: View {
    @Environment(\.dismiss) private var dismiss
    let table: DataTable
    let onAdd: (ViewSortOrder) -> Void
    
    @State private var selectedFieldId: String?
    @State private var ascending = true
    @State private var groupByValue = false
    
    // 统一颜色定义
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
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
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                List {
                    // 字段选择部分
                    Section("字段") {
                        ForEach(table.fields) { field in
                            HStack {
                                Text(field.name)
                                    .foregroundColor(mainColor)
                                Spacer()
                                if selectedFieldId == field.id.uuidString {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accentColor)
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
                                    .foregroundColor(mainColor)
                                Spacer()
                                if selectedFieldId == systemField.rawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(accentColor)
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
                                .foregroundColor(accentColor)
                            Button("升序") {
                                ascending = true
                            }
                            .foregroundColor(mainColor)
                            Spacer()
                            if ascending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundColor(accentColor)
                            Button("降序") {
                                ascending = false
                            }
                            .foregroundColor(mainColor)
                            Spacer()
                            if !ascending {
                                Image(systemName: "checkmark")
                                    .foregroundColor(accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    
                    // 按值分组部分
                    Section {
                        Toggle("按值分组", isOn: $groupByValue)
                            .tint(accentColor)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("排序方式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
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
                    .foregroundColor(accentColor)
                }
            }
        }
    }
} 