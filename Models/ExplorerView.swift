import SwiftUI
import SwiftData

@Model
class ExplorerView {
    // 基本信息
    var id: UUID
    var tableId: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    // 视图模式
    var viewMode: ViewMode // "grid" 或 "card"
    
    // 网格视图配置
    var columnWidths: [UUID: Double] // 字段ID: 宽度
    var columnOrder: [UUID] // 字段ID顺序
    
    // 卡片视图配置
    var columnsCount: Int
    var cardSize: Double
    var displayFields: [UUID] // 要显示的字段ID
    
    // 排序和过滤
    var sortField: String?
    var sortAscending: Bool
    var filterRules: [FilterRule]
    
    var sortIndex: Int = 0
    
    init(
        tableId: UUID,
        name: String = "默认视图",
        viewMode: ViewMode = .grid,
        columnsCount: Int = 3,
        cardSize: Double = 200,
        sortAscending: Bool = true
    ) {
        self.id = UUID()
        self.tableId = tableId
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.viewMode = viewMode
        self.columnWidths = [:]
        self.columnOrder = []
        self.columnsCount = columnsCount
        self.cardSize = cardSize
        self.displayFields = []
        self.sortAscending = sortAscending
        self.filterRules = []
    }
}

// 过滤规则模型
@Model
class FilterRule {
    var id: UUID
    var fieldId: UUID
    var operation: String
    var value: String
    
    init(fieldId: UUID, operation: String, value: String) {
        self.id = UUID()
        self.fieldId = fieldId
        self.operation = operation
        self.value = value
    }
}

// 视图模式枚举
enum ViewMode: String, Codable {
    case grid = "grid"
    case card = "card"
    case custom = "custom"
}
