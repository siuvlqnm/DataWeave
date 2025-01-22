import SwiftUI
import SwiftData

struct CardExplorerView: View {
    let records: [DataRecord]
    let fields: [DataField]
    @Binding var selectedRecords: Set<UUID>
    let config: ExplorerViewConfig
    
    // 布局配置
    @State private var columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    @State private var cardSize: CGFloat = 200
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    
    var body: some View {
        VStack(spacing: 16) {
            // 布局控制器
            HStack {
                // 列数调整
                Stepper(
                    "列数: \(columns.count)",
                    value: Binding(
                        get: { columns.count },
                        set: { columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: max(1, min($0, 6))) }
                    ),
                    in: 1...6
                )
                
                Divider()
                    .padding(.horizontal)
                
                // 卡片大小调整
                HStack {
                    Text("卡片大小")
                    Slider(
                        value: $cardSize,
                        in: 150...300
                    )
                }
            }
            .padding(.horizontal)
            
            // 卡片网格
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(records) { record in
                        CardView(
                            record: record,
                            fields: fields,
                            isSelected: selectedRecords.contains(record.id),
                            onSelect: { isSelected in
                                if isSelected {
                                    selectedRecords.insert(record.id)
                                } else {
                                    selectedRecords.remove(record.id)
                                }
                            }
                        )
                        .frame(height: cardSize)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - 子组件

private struct CardView: View {
    let record: DataRecord
    let fields: [DataField]
    let isSelected: Bool
    let onSelect: (Bool) -> Void
    
    private var displayFields: [DataField] {
        // 优先显示图片字段，然后是标题字段，最后是其他字段
        var result: [DataField] = []
        
        // 首先添加图片字段
        let imageFields = fields.filter { $0.type == .image }
        result.append(contentsOf: imageFields)
        
        // 然后添加标题字段（通常是第一个文本字段）
        if let titleField = fields.first(where: { $0.type == .text }) {
            if !result.contains(where: { $0.id == titleField.id }) {
                result.append(titleField)
            }
        }
        
        // 最后添加其他字段，直到达到最大显示数量
        let remainingFields = fields.filter { field in
            !result.contains(where: { $0.id == field.id })
        }
        
        result.append(contentsOf: remainingFields.prefix(3))
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 卡片内容
            VStack(alignment: .leading, spacing: 8) {
                ForEach(displayFields) { field in
                    FieldValueView(
                        field: field,
                        value: record.values[field.id] ?? ""
                    )
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // 底部操作栏
            HStack {
                Button(action: { onSelect(!isSelected) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                }
                
                Spacer()
                
                Text(record.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(Color(.systemGray6))
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
}

private struct FieldValueView: View {
    let field: DataField
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 字段名称
            Text(field.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 字段值
            switch field.type {
            case .image:
                if let url = URL(string: value) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .cornerRadius(8)
                }
            case .boolean:
                Image(systemName: value == "true" ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(value == "true" ? .green : .red)
            default:
                Text(value)
                    .font(.system(size: 14))
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataTable.self, configurations: config)
    
    // 创建测试数据
    let table = DataTable(name: "测试表", description: "这是一个测试表")
    let field1 = DataField(name: "标题", type: .text)
    let field2 = DataField(name: "图片", type: .image)
    let field3 = DataField(name: "状态", type: .boolean)
    table.fields = [field1, field2, field3]
    
    let record1 = DataRecord(table: table)
    record1.values = [
        field1.id: "示例卡片 1",
        field2.id: "https://picsum.photos/200",
        field3.id: "true"
    ]
    
    let record2 = DataRecord(table: table)
    record2.values = [
        field1.id: "示例卡片 2",
        field2.id: "https://picsum.photos/200",
        field3.id: "false"
    ]
    
    return CardExplorerView(
        records: [record1, record2],
        fields: table.fields,
        selectedRecords: .constant([]),
        config: ExplorerViewConfig(tableId: UUID().uuidString)
    )
    .padding()
} 