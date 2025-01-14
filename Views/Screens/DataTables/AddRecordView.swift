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
                        // 按sortIndex排序展示字段
                        ForEach(table.fields.sorted(by: { $0.sortIndex < $1.sortIndex })) { field in
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
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isFirstAppear = true
    
    init(type: DataField.FieldType, value: Binding<String>) {
        self.type = type
        self._value = value
        
        // 只初始化 State 变量
        let now = Date()
        self._selectedDate = State(initialValue: now)
        self._selectedTime = State(initialValue: now)
        self._isFirstAppear = State(initialValue: true)
    }
    
    var body: some View {
        // case text = "文本"
        // case richText = "富文本"
        // case number = "数字"
        // case decimal = "小数"
        // case boolean = "布尔"
        // case date = "日期"
        // case time = "时间"
        // case dateTime = "日期时间"
        // // 媒体类型
        // case image = "图片"
        // case file = "文件"
        // // 联系信息
        // case email = "邮箱"
        // case phone = "电话"
        // case url = "链接"
        // case location = "位置"
        // // 特殊类型
        // case color = "颜色"
        // case barcode = "条形码"
        // case qrCode = "二维码"
        Group{
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
                
            case .decimal:
                TextField("请输入小数", text: $value)
                    .textFieldStyle(.plain)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            
            case .date:
                HStack {
                    Text(value.isEmpty ? "选择日期" : value)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    showDatePicker = true
                }
                
            case .time:
                HStack {
                    Text(value.isEmpty ? "选择时间" : value)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    showTimePicker = true
                }
                
            case .dateTime:
                HStack {
                    Text(value.isEmpty ? "选择日期和时间" : value)
                        .foregroundColor(value.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "calendar.clock")
                        .foregroundColor(.gray)
                    
                    // 分开的日期和时间选择按钮
                    HStack(spacing: 8) {
                        Button(action: { showDatePicker = true }) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: { showTimePicker = true }) {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                // .onTapGesture {
                //     showDatePicker = true
                // }
            
            case .boolean:
                Toggle(isOn: Binding(
                    get: { value == "true" },
                    set: { value = $0 ? "true" : "false" }
                )) {
                    Text("布尔")
                }
            
            // case .image:
            //     ImagePickerView(image: $image)
            //         .frame(height: 100)
            //         .padding(4)
            //         .background(Color.gray.opacity(0.1))
            //         .cornerRadius(8)
                
            // TODO: 实现其他类型的输入控件
            default:
                TextField("请输入", text: $value)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .onAppear {
            if isFirstAppear && value.isEmpty {
                let formatter = DateFormatter()
                
                switch type {
                case .date:
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .none
                    value = formatter.string(from: Date())
                    
                case .time:
                    formatter.dateStyle = .none
                    formatter.timeStyle = .short
                    value = formatter.string(from: Date())
                    
                case .dateTime:
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    value = formatter.string(from: Date())
                    
                default:
                    break
                }
                isFirstAppear = false
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .navigationTitle("选择日期")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            formatter.timeStyle = .none
                            value = formatter.string(from: selectedDate)
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTimePicker) {
            NavigationView {
                VStack {
                    Spacer()
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    Spacer()
                }
                .navigationTitle("选择时间")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showTimePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .none
                            formatter.timeStyle = .short
                            value = formatter.string(from: selectedTime)
                            showTimePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
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
