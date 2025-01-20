import SwiftUI
import SwiftData

struct AddFilterView: View {
    @Environment(\.dismiss) private var dismiss
    let table: DataTable
    let onAdd: (ViewFilter) -> Void
    
    @State private var selectedFieldId: String?
    @State private var selectedOperation: ViewFilter.FilterOperation = .equals
    @State private var filterValue = ""
    
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
                
                VStack {
                    List {
                        // 字段选择部分
                        Section {
                            Menu {
                                ForEach(table.fields) { field in
                                    Button(action: {
                                        selectedFieldId = field.id.uuidString
                                    }) {
                                        HStack {
                                            Text(field.name)
                                            if selectedFieldId == field.id.uuidString {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                                
                                // 系统字段选项
                                ForEach(SystemField.allCases, id: \.self) { systemField in
                                    Button(action: {
                                        selectedFieldId = systemField.rawValue
                                    }) {
                                        HStack {
                                            Text(systemField.name)
                                            if selectedFieldId == systemField.rawValue {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("字段")
                                        .foregroundColor(mainColor)
                                    Spacer()
                                    if let fieldId = selectedFieldId {
                                        if let field = table.fields.first(where: { $0.id.uuidString == fieldId }) {
                                            Text(field.name)
                                        } else if let systemField = SystemField(rawValue: fieldId) {
                                            Text(systemField.name)
                                        }
                                    }
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        // 操作选择部分
                        if selectedFieldId != nil {
                            Section {
                                Menu {
                                    ForEach(ViewFilter.FilterOperation.allCases, id: \.self) { operation in
                                        Button(action: {
                                            selectedOperation = operation
                                        }) {
                                            HStack {
                                                Text(operation.rawValue)
                                                if selectedOperation == operation {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text("操作")
                                            .foregroundColor(mainColor)
                                        Spacer()
                                        Text(selectedOperation.rawValue)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            // 值输入部分
                            if !isEmptyValueOperation(selectedOperation) {
                                Section {
                                    TextField("请输入筛选值", text: $filterValue)
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // 保存按钮
                    Button(action: {
                        if let fieldId = selectedFieldId {
                            let filter = ViewFilter(
                                fieldId: fieldId,
                                operation: selectedOperation,
                                value: filterValue
                            )
                            onAdd(filter)
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("保存过滤器")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedFieldId == nil ? Color.gray : accentColor)
                        .cornerRadius(8)
                    }
                    .disabled(selectedFieldId == nil)
                    .padding()
                }
            }
            .navigationTitle("新建过滤器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("应用") {
                        if let fieldId = selectedFieldId {
                            let filter = ViewFilter(
                                fieldId: fieldId,
                                operation: selectedOperation,
                                value: filterValue
                            )
                            onAdd(filter)
                            dismiss()
                        }
                    }
                    .disabled(selectedFieldId == nil)
                }
            }
        }
    }
    
    // 判断是否是不需要输入值的操作（如"为空"、"不为空"）
    private func isEmptyValueOperation(_ operation: ViewFilter.FilterOperation) -> Bool {
        return operation == .isEmpty || operation == .isNotEmpty
    }
} 