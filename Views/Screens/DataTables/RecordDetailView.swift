import SwiftUI

struct RecordDetailView: View {
    let record: DataRecord
    @Environment(\.dismiss) private var dismiss
    
    private var sortedFields: [(name: String, value: String)] {
        record.values.sorted(by: { $0.key < $1.key }).map { fieldId, value in
            (
                name: record.table?.fields.first(where: { $0.id == fieldId })?.name ?? "未知字段",
                value: value
            )
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("基本信息") {
                    LabeledContent("记录 ID", value: record.id.uuidString)
                    LabeledContent("创建时间", value: record.createdAt.formatted())
                    LabeledContent("更新时间", value: record.updatedAt.formatted())
                }
                
                Section("字段数据") {
                    ForEach(sortedFields, id: \.name) { field in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(field.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(field.value)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("记录详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    let table = DataTable(name: "测试表")
    let record = DataRecord(table: table)
    record.setValue("张三", for: DataField(name: "姓名", type: .text))
    record.setValue("25", for: DataField(name: "年龄", type: .number))
    record.setValue("这是一段简介", for: DataField(name: "简介", type: .richText))
    
    return RecordDetailView(record: record)
} 