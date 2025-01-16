// import SwiftUI
// import SwiftData

// struct EditRecordView: View {
//     let record: DataRecord
//     @Environment(\.dismiss) private var dismiss
//     @Environment(\.modelContext) private var modelContext
    
//     @State private var values: [UUID: String] = [:]
    
//     private let mainColor = Color(hex: "1A202C")
//     private let accentColor = Color(hex: "A020F0")
//     private let backgroundColor = Color(hex: "FAF0E6")
    
//     init(record: DataRecord) {
//         self.record = record
//         _values = State(initialValue: record.values)
//     }
    
//     var body: some View {
//         NavigationView {
//             ZStack {
//                 backgroundColor.ignoresSafeArea()
                
//                 ScrollView {
//                     VStack(spacing: 20) {
//                         if let fields = record.table?.fields.sorted(by: { $0.sortIndex < $1.sortIndex }) {
//                             ForEach(fields) { field in
//                                 VStack(alignment: .leading, spacing: 8) {
//                                     // 字段标题
//                                     HStack {
//                                         Image(systemName: field.type.icon)
//                                             .foregroundColor(accentColor)
//                                         Text(field.name)
//                                             .font(.system(size: 14, weight: .medium))
//                                         if field.isRequired {
//                                             Text("*")
//                                                 .foregroundColor(.red)
//                                         }
//                                     }
                                    
//                                     // 使用相同的 FieldInputView
//                                     FieldInputView(
//                                         type: field.type,
//                                         value: Binding(
//                                             get: { values[field.id] ?? "" },
//                                             set: { values[field.id] = $0 }
//                                         )
//                                     )
//                                 }
//                                 .padding()
//                                 .background(Color.white)
//                                 .cornerRadius(12)
//                                 .shadow(color: Color.black.opacity(0.05), radius: 5)
//                             }
//                         }
//                     }
//                     .padding()
//                 }
//             }
//             .navigationTitle("编辑记录")
//             .navigationBarTitleDisplayMode(.inline)
//             .toolbar {
//                 ToolbarItem(placement: .cancellationAction) {
//                     Button("取消") {
//                         dismiss()
//                     }
//                     .foregroundColor(mainColor)
//                 }
                
//                 ToolbarItem(placement: .confirmationAction) {
//                     Button("保存") {
//                         // 更新记录
//                         record.values = values
//                         try? modelContext.save()
//                         dismiss()
//                     }
//                     .disabled(!isValidRecord)
//                     .foregroundColor(isValidRecord ? accentColor : .gray)
//                 }
//             }
//         }
//     }
    
//     private var isValidRecord: Bool {
//         // 检查所有必填字段是否都有值
//         guard let fields = record.table?.fields else { return true }
//         for field in fields where field.isRequired {
//             if values[field.id]?.isEmpty ?? true {
//                 return false
//             }
//         }
//         return true
//     }
// }

// #Preview {
//     let table = DataTable(name: "测试表")
//     let record = DataRecord(table: table)
//     record.setValue("张三", for: DataField(name: "姓名", type: .text))
//     record.setValue("25", for: DataField(name: "年龄", type: .number))
    
//     return EditRecordView(record: record)
// }
