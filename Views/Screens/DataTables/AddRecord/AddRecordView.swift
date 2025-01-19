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
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
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
                                
                                // 使用新的 FieldInputRow 组件
                                FieldInputRow(
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
        for field in table.fields where field.isRequired {
            if fieldValues[field.id]?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    private func saveRecord() {
        let record = DataRecord(table: table)
        
        // 确保 sortIndex 最小的字段的 showInList 为 true
        if let firstField = table.fields.min(by: { $0.sortIndex < $1.sortIndex }) {
            firstField.showInList = true
        }
        
        for field in table.fields {
            let value = fieldValues[field.id] ?? ""
            record.setValue(value, for: field)
        }
        
        modelContext.insert(record)
        try? modelContext.save()
        dismiss()
    }
}

// 字段输入控件
// struct FieldInputView: View {
//     let type: DataField.FieldType
//     @Binding var value: String
    
//     @State private var selectedDate = Date()
//     @State private var selectedTime = Date()
//     @State private var showDatePicker = false
//     @State private var showTimePicker = false
//     @State private var isFirstAppear = true
//     @State private var showImagePicker = false
//     @State private var selectedImage: UIImage?
//     @State private var imageData: Data?
    
//     init(type: DataField.FieldType, value: Binding<String>) {
//         self.type = type
//         self._value = value
        
//         let now = Date()
//         self._selectedDate = State(initialValue: now)
//         self._selectedTime = State(initialValue: now)
        
//         // 初始化时设置完整的日期和时间
//         if value.wrappedValue.isEmpty {
//             let dateFormatter = DateFormatter()
//             dateFormatter.dateFormat = "yyyy年MM月dd日"
//             let timeFormatter = DateFormatter()
//             timeFormatter.dateFormat = "HH:mm"
            
//             switch type {
//             case .date:
//                 value.wrappedValue = dateFormatter.string(from: now)
//             case .time:
//                 value.wrappedValue = timeFormatter.string(from: now)
//             case .dateTime:
//                 value.wrappedValue = "\(dateFormatter.string(from: now)) \(timeFormatter.string(from: now))"
//             default:
//                 break
//             }
//         }
//     }
    
//     var body: some View {
//         // case text = "文本"
//         // case richText = "富文本"
//         // case number = "数字"
//         // case decimal = "小数"
//         // case boolean = "布尔"
//         // case date = "日期"
//         // case time = "时间"
//         // case dateTime = "日期时间"
//         // // 媒体类型
//         // case image = "图片"
//         // case file = "文件"
//         // // 联系信息
//         // case email = "邮箱"
//         // case phone = "电话"
//         // case url = "链接"
//         // case location = "位置"
//         // // 特殊类型
//         // case color = "颜色"
//         // case barcode = "条形码"
//         // case qrCode = "二维码"
//         Group{
//             switch type {
//             case .text:
//                 TextField("请输入文本", text: $value)
//                     .textFieldStyle(.plain)
//                     .padding()
//                     .background(Color.gray.opacity(0.1))
//                     .cornerRadius(8)
                
//             case .richText:
//                 TextEditor(text: $value)
//                     .frame(height: 100)
//                     .padding(4)
//                     .background(Color.gray.opacity(0.1))
//                     .cornerRadius(8)
                
//             case .number:
//                 TextField("请输入数字", text: $value)
//                     .textFieldStyle(.plain)
//                     .keyboardType(.numberPad)
//                     .padding()
//                     .background(Color.gray.opacity(0.1))
//                     .cornerRadius(8)
                
//             case .decimal:
//                 TextField("请输入小数", text: $value)
//                     .textFieldStyle(.plain)
//                     .keyboardType(.decimalPad)
//                     .padding()
//                     .background(Color.gray.opacity(0.1))
//                     .cornerRadius(8)
            
//             case .date:
//                 HStack {
//                     Text(value.isEmpty ? "选择日期" : value)
//                         .foregroundColor(value.isEmpty ? .secondary : .primary)
//                     Spacer()
//                 }
//                 .padding()
//                 .background(Color.gray.opacity(0.1))
//                 .cornerRadius(8)
//                 .onTapGesture {
//                     showDatePicker = true
//                 }
//                 .sheet(isPresented: $showDatePicker) {
//                     NavigationView {
//                         DatePicker(
//                             "选择日期",
//                             selection: $selectedDate,
//                             displayedComponents: [.date]
//                         )
//                         .datePickerStyle(.graphical)
//                         .navigationTitle("选择日期")
//                         .navigationBarTitleDisplayMode(.inline)
//                         .toolbar {
//                             ToolbarItem(placement: .cancellationAction) {
//                                 Button("取消") {
//                                     showDatePicker = false
//                                 }
//                             }
//                             ToolbarItem(placement: .confirmationAction) {
//                                 Button("保存") {
//                                     let formatter = DateFormatter()
//                                     formatter.dateFormat = "yyyy年MM月dd日"
//                                     value = formatter.string(from: selectedDate)
//                                     showDatePicker = false
//                                 }
//                             }
//                         }
//                     }
//                     .presentationDetents([.medium])
//                 }
                
//             case .time:
//                 HStack {
//                     Text(value.isEmpty ? "选择时间" : value)
//                         .foregroundColor(value.isEmpty ? .secondary : .primary)
//                     Spacer()
//                 }
//                 .padding()
//                 .background(Color.gray.opacity(0.1))
//                 .cornerRadius(8)
//                 .onTapGesture {
//                     showTimePicker = true
//                 }
//                 .sheet(isPresented: $showTimePicker) {
//                     NavigationView {
//                         VStack {
//                             Spacer()
//                             DatePicker(
//                                 "",
//                                 selection: $selectedTime,
//                                 displayedComponents: [.hourAndMinute]
//                             )
//                             .datePickerStyle(.wheel)
//                             .labelsHidden()
//                             Spacer()
//                         }
//                         .navigationTitle("选择时间")
//                         .navigationBarTitleDisplayMode(.inline)
//                         .toolbar {
//                             ToolbarItem(placement: .cancellationAction) {
//                                 Button("取消") {
//                                     showTimePicker = false
//                                 }
//                             }
//                             ToolbarItem(placement: .confirmationAction) {
//                                 Button("保存") {
//                                     let formatter = DateFormatter()
//                                     formatter.dateFormat = "HH:mm"
//                                     value = formatter.string(from: selectedTime)
//                                     showTimePicker = false
//                                 }
//                             }
//                         }
//                     }
//                     .presentationDetents([.height(300)])
//                 }
                
//             case .dateTime:
//                 HStack(spacing: 4) {
//                     // 日期部分
//                     Text(getDatePart(from: value))
//                         .foregroundColor(value.isEmpty ? .secondary : .primary)
//                         .frame(maxWidth: .infinity, alignment: .leading)
//                         .onTapGesture {
//                             showDatePicker = true
//                         }
                    
//                     // 时间部分
//                     Text(getTimePart(from: value))
//                         .foregroundColor(value.isEmpty ? .secondary : .primary)
//                         .frame(maxWidth: .infinity, alignment: .leading)
//                         .onTapGesture {
//                             showTimePicker = true
//                         }
//                 }
//                 .padding()
//                 .background(Color.gray.opacity(0.1))
//                 .cornerRadius(8)
//                 .sheet(isPresented: $showDatePicker) {
//                     NavigationView {
//                         DatePicker(
//                             "选择日期",
//                             selection: $selectedDate,
//                             displayedComponents: [.date]
//                         )
//                         .datePickerStyle(.graphical)
//                         .navigationTitle("选择日期")
//                         .navigationBarTitleDisplayMode(.inline)
//                         .toolbar {
//                             ToolbarItem(placement: .cancellationAction) {
//                                 Button("取消") {
//                                     showDatePicker = false
//                                 }
//                             }
//                             ToolbarItem(placement: .confirmationAction) {
//                                 Button("保存") {
//                                     let dateFormatter = DateFormatter()
//                                     dateFormatter.dateFormat = "yyyy年MM月dd日"
//                                     let newDate = dateFormatter.string(from: selectedDate)
//                                     let currentTime = getTimePart(from: value)
//                                     if currentTime == "选择时间" {
//                                         let timeFormatter = DateFormatter()
//                                         timeFormatter.dateFormat = "HH:mm"
//                                         value = "\(newDate) \(timeFormatter.string(from: Date()))"
//                                     } else {
//                                         value = "\(newDate) \(currentTime)"
//                                     }
//                                     showDatePicker = false
//                                 }
//                             }
//                         }
//                     }
//                     .presentationDetents([.medium])
//                 }
//                 .sheet(isPresented: $showTimePicker) {
//                     NavigationView {
//                         VStack {
//                             Spacer()
//                             DatePicker(
//                                 "",
//                                 selection: $selectedTime,
//                                 displayedComponents: [.hourAndMinute]
//                             )
//                             .datePickerStyle(.wheel)
//                             .labelsHidden()
//                             Spacer()
//                         }
//                         .navigationTitle("选择时间")
//                         .navigationBarTitleDisplayMode(.inline)
//                         .toolbar {
//                             ToolbarItem(placement: .cancellationAction) {
//                                 Button("取消") {
//                                     showTimePicker = false
//                                 }
//                             }
//                             ToolbarItem(placement: .confirmationAction) {
//                                 Button("保存") {
//                                     let timeFormatter = DateFormatter()
//                                     timeFormatter.dateFormat = "HH:mm"
//                                     let newTime = timeFormatter.string(from: selectedTime)
//                                     let currentDate = getDatePart(from: value)
//                                     if currentDate == "选择日期" {
//                                         let dateFormatter = DateFormatter()
//                                         dateFormatter.dateFormat = "yyyy年MM月dd日"
//                                         value = "\(dateFormatter.string(from: Date())) \(newTime)"
//                                     } else {
//                                         value = "\(currentDate) \(newTime)"
//                                     }
//                                     showTimePicker = false
//                                 }
//                             }
//                         }
//                     }
//                     .presentationDetents([.height(300)])
//                 }
            
//             case .boolean:
//                 Toggle(isOn: Binding(
//                     get: { value == "true" },
//                     set: { value = $0 ? "true" : "false" }
//                 )) {
//                     Text("布尔")
//                 }
            
//             case .image:
//                 VStack(alignment: .leading, spacing: 8) {
//                     if let image = selectedImage {
//                         Image(uiImage: image)
//                             .resizable()
//                             .scaledToFit()
//                             .frame(height: 200)
//                             .frame(maxWidth: .infinity)
//                             .cornerRadius(8)
//                             .onTapGesture {
//                                 showImagePicker = true
//                             }
//                     } else {
//                         HStack {
//                             Spacer()
//                             VStack(spacing: 12) {
//                                 Image(systemName: "photo")
//                                     .font(.system(size: 40))
//                                     .foregroundColor(.gray)
//                                 Text("点击选择图片")
//                                     .font(.system(size: 14))
//                                     .foregroundColor(.gray)
//                             }
//                             Spacer()
//                         }
//                         .frame(height: 200)
//                         .background(Color.gray.opacity(0.1))
//                         .cornerRadius(8)
//                         .onTapGesture {
//                             showImagePicker = true
//                         }
//                     }
//                 }
//                 .sheet(isPresented: $showImagePicker) {
//                     ImagePicker(image: $selectedImage) { image in
//                         if let imageData = image.jpegData(compressionQuality: 0.7) {
//                             self.imageData = imageData
//                             // 将图片数据转换为 Base64 字符串存储
//                             value = imageData.base64EncodedString()
//                         }
//                     }
//                 }
            
//             // TODO: 实现其他类型的输入控件
//             default:
//                 TextField("请输入", text: $value)
//                     .textFieldStyle(.plain)
//                     .padding()
//                     .background(Color.gray.opacity(0.1))
//                     .cornerRadius(8)
//             }
//         }
//         .onAppear {
//             if isFirstAppear && value.isEmpty {
//                 let formatter = DateFormatter()
                
//                 switch type {
//                 case .date:
//                     formatter.dateFormat = "yyyy年MM月dd日"
//                     value = formatter.string(from: Date())
                    
//                 case .time:
//                     formatter.dateFormat = "HH:mm"
//                     value = formatter.string(from: Date())
                    
//                 case .dateTime:
//                     formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
//                     value = formatter.string(from: Date())
                    
//                 default:
//                     break
//                 }
//                 isFirstAppear = false
//             }
//         }
//     }
    
//     private func getDatePart(from value: String) -> String {
//         if value.isEmpty {
//             return "选择日期"
//         }
//         let components = value.components(separatedBy: " ")
//         let datePart = components.first ?? ""
//         return datePart.isEmpty ? "选择日期" : datePart
//     }
    
//     private func getTimePart(from value: String) -> String {
//         if value.isEmpty {
//             return "选择时间"
//         }
//         let components = value.components(separatedBy: " ")
//         let timePart = components.count > 1 ? components[1] : ""
//         return timePart.isEmpty ? "选择时间" : timePart
//     }
// }

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
