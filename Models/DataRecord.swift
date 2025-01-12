import SwiftUI
import SwiftData

@Model
final class DataRecord {
    @Attribute(.unique) var id: UUID
    var values: [UUID: String] // 存储字段值，key 是字段 id
    var createdAt: Date
    var updatedAt: Date
    var table: DataTable? // 关联的数据表
    
    init(table: DataTable) {
        self.id = UUID()
        self.values = [:]
        self.createdAt = Date()
        self.updatedAt = Date()
        self.table = table
    }
    
    // 便利方法：获取字段值
    func getValue(for field: DataField) -> String {
        return values[field.id] ?? ""
    }
    
    // 便利方法：设置字段值
    func setValue(_ value: String, for field: DataField) {
        values[field.id] = value
        updatedAt = Date()
    }
} 