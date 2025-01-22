import SwiftUI
import SwiftData

struct GridExplorerView: View {
    let records: [DataRecord]
    let fields: [DataField]
    @Binding var selectedRecords: Set<UUID>
    let config: ExplorerViewConfig
    
    // 列宽调整状态
    @State private var columnWidths: [UUID: CGFloat] = [:]
    @State private var isDraggingColumn: UUID?
    
    private let defaultColumnWidth: CGFloat = 150
    private let minColumnWidth: CGFloat = 80
    private let headerHeight: CGFloat = 40
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                // 表头
                HStack(spacing: 0) {
                    // 选择框列
                    SelectionHeaderCell()
                    
                    // 字段列
                    ForEach(fields) { field in
                        GridHeaderCell(
                            field: field,
                            width: columnWidths[field.id] ?? defaultColumnWidth,
                            onDragChanged: { width in
                                if let newWidth = updateColumnWidth(field: field, dragWidth: width) {
                                    columnWidths[field.id] = newWidth
                                }
                            }
                        )
                    }
                }
                .frame(height: headerHeight)
                .background(Color(.systemGray6))
                
                // 数据行
                ForEach(records) { record in
                    // 将复杂的表达式拆分为多个部分
                    let isSelected = selectedRecords.contains(record.id)
                    GridRow(
                        record: record,
                        fields: fields,
                        columnWidths: columnWidths,
                        defaultWidth: defaultColumnWidth,
                        isSelected: isSelected,
                        onSelect: { selected in
                            if selected {
                                selectedRecords.insert(record.id)
                            } else {
                                selectedRecords.remove(record.id)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private func updateColumnWidth(field: DataField, dragWidth: CGFloat) -> CGFloat? {
        let newWidth = max(minColumnWidth, dragWidth)
        return newWidth
    }
}

// MARK: - 子组件

private struct SelectionHeaderCell: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 44)
            .overlay(
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.gray)
            )
            .border(Color(.systemGray4), width: 0.5)
    }
}

private struct GridHeaderCell: View {
    let field: DataField
    let width: CGFloat
    let onDragChanged: (CGFloat) -> Void
    
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            // 字段名称
            HStack(spacing: 4) {
                Image(systemName: field.type.icon)
                    .foregroundColor(.gray)
                Text(field.name)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 8)
            
            Spacer()
            
            // 拖动调整手柄
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 1, height: 16)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                            onDragChanged(width + dragOffset)
                        }
                        .onEnded { _ in
                            dragOffset = 0
                        }
                )
        }
        .frame(width: width)
        .border(Color(.systemGray4), width: 0.5)
    }
}

private struct GridRow: View {
    let record: DataRecord
    let fields: [DataField]
    let columnWidths: [UUID: CGFloat]
    let defaultWidth: CGFloat
    let isSelected: Bool
    let onSelect: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // 选择框
            SelectionCell(isSelected: isSelected, onSelect: onSelect)
            
            // 字段值
            ForEach(fields) { field in
                GridCell(
                    value: record.values[field.id] ?? "",
                    width: columnWidths[field.id] ?? defaultWidth,
                    type: field.type
                )
            }
        }
        .frame(height: 44)
        .background(isSelected ? Color(.systemGray6) : Color.white)
    }
}

private struct SelectionCell: View {
    let isSelected: Bool
    let onSelect: (Bool) -> Void
    
    var body: some View {
        Button(action: { onSelect(!isSelected) }) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(width: 44)
        }
        .buttonStyle(.plain)
        .border(Color(.systemGray4), width: 0.5)
    }
}

private struct GridCell: View {
    let value: String
    let width: CGFloat
    let type: DataField.FieldType
    
    var body: some View {
        HStack {
            switch type {
            case .image:
                // 图片预览
                if let url = URL(string: value) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                    } placeholder: {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
            case .boolean:
                // 布尔值显示
                Image(systemName: value == "true" ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(value == "true" ? .green : .gray)
            default:
                // 文本显示
                Text(value)
                    .font(.system(size: 14))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 8)
        .frame(width: width, alignment: .leading)
        .border(Color(.systemGray4), width: 0.5)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataTable.self, configurations: config)
    
    // 创建测试数据
    let table = DataTable(name: "测试表", description: "这是一个测试表")
    let field1 = DataField(name: "姓名", type: .text)
    let field2 = DataField(name: "年龄", type: .number)
    table.fields = [field1, field2]
    
    let record1 = DataRecord(table: table)
    record1.values = [
        field1.id: "张三",
        field2.id: "25"
    ]
    
    let record2 = DataRecord(table: table)
    record2.values = [
        field1.id: "李四",
        field2.id: "30"
    ]
    
    return GridExplorerView(
        records: [record1, record2],
        fields: table.fields,
        selectedRecords: .constant([]),
        config: ExplorerViewConfig(tableId: UUID().uuidString)
    )
    .padding()
} 