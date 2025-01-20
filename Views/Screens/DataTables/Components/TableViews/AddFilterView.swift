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
                        
                        // 操作选择部分
                        if selectedFieldId != nil {
                            Section("操作") {
                                ForEach(ViewFilter.FilterOperation.allCases, id: \.self) { operation in
                                    HStack {
                                        Text(operation.rawValue)
                                            .foregroundColor(mainColor)
                                        Spacer()
                                        if selectedOperation == operation {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(accentColor)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedOperation = operation
                                    }
                                }
                            }
                            
                            // 值输入部分
                            if !isEmptyValueOperation(selectedOperation) {
                                Section("值") {
                                    TextField("请输入筛选值", text: $filterValue)
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // 添加过滤按钮
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
                            Image(systemName: "plus.circle.fill")
                            Text("添加过滤")
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
            .navigationTitle("添加过滤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
    }
    
    // 判断是否是不需要输入值的操作（如"为空"、"不为空"）
    private func isEmptyValueOperation(_ operation: ViewFilter.FilterOperation) -> Bool {
        return operation == .isEmpty || operation == .isNotEmpty
    }
} 