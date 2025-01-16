import SwiftUI
import MapKit

struct RecordDetailView: View {
    let record: DataRecord
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showEditRecord = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    private var sortedFields: [(name: String, value: String, icon: String, type: DataField.FieldType)] {
        guard let fields = record.table?.fields else { return [] }
        
        let sortedTableFields = fields.sorted(by: { $0.sortIndex < $1.sortIndex })
        
        return sortedTableFields.compactMap { field in
            guard let value = record.values[field.id] else { return nil }
            return (
                name: field.name,
                value: value,
                icon: field.type.icon,
                type: field.type
            )
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {  // 减小卡片间距
                    // 记录ID和时间信息
                    HStack {
                        Text("#\(record.id.uuidString.prefix(8))")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(record.createdAt.formatted())
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    
                    // 字段内容卡片
                    ForEach(sortedFields, id: \.name) { field in
                        VStack(alignment: .leading, spacing: 8) {
                            // 字段标题
                            HStack(spacing: 8) {
                                Image(systemName: field.icon)
                                    .foregroundColor(accentColor)
                                    .frame(width: 20)
                                Text(field.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(mainColor)
                            }
                            
                            // 字段值
                            Group {
                                if field.type == .image, let imageData = Data(base64Encoded: field.value) {
                                    Image(uiImage: UIImage(data: imageData) ?? UIImage())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                } else if field.type == .location, let coordinate = parseCoordinate(from: field.value) {
                                    Map(position: .constant(MapCameraPosition.region(MKCoordinateRegion(
                                        center: coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )))) {
                                        Marker("位置", coordinate: coordinate)
                                    }
                                    .frame(height: 200)
                                    .cornerRadius(8)
                                } else {
                                    Text(field.value)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                        .background(Color.white.opacity(0.5))
                                        .cornerRadius(6)
                                }
                            }
                            .textSelection(.enabled)
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(12)  // 减小整体边距
            }
        }
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showEditRecord = true
                    }) {
                        Label("编辑", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // 添加分享功能
                    }) {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        modelContext.delete(record)
                        dismiss()
                    }) {
                        Label("删除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(accentColor)
                }
            }
        }
        .sheet(isPresented: $showEditRecord) {
            EditRecordView(record: record)
        }
    }
    
    private func parseCoordinate(from string: String) -> CLLocationCoordinate2D? {
        let components = string.split(separator: ",")
        guard components.count == 2,
              let latitude = Double(components[0]),
              let longitude = Double(components[1]) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

private struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(Color(hex: "1A202C"))
        }
        .font(.system(size: 14))
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