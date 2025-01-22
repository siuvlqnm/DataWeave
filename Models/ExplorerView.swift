import SwiftUI
import SwiftData

@Model
class ExplorerView {
    // 基本信息
    var id: String
    var tableId: String
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    // 视图模式
    var viewMode: String // "grid" 或 "card"
    
    // 网格视图配置
    var columnWidths: [String: Double] // 字段ID: 宽度
    var columnOrder: [String] // 字段ID顺序
    
    // 卡片视图配置
    var columnsCount: Int
    var cardSize: Double
    var displayFields: [String] // 要显示的字段ID
    
    // 排序和过滤
    var sortField: String?
    var sortAscending: Bool
    var filterRules: [FilterRule]
    
    var sortIndex: Int = 0
    
    init(
        tableId: String,
        name: String = "默认视图",
        viewMode: String = "grid",
        columnsCount: Int = 3,
        cardSize: Double = 200,
        sortAscending: Bool = true
    ) {
        self.id = UUID().uuidString
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
    var id: String
    var fieldId: String
    var operation: String
    var value: String
    
    init(fieldId: String, operation: String, value: String) {
        self.id = UUID().uuidString
        self.fieldId = fieldId
        self.operation = operation
        self.value = value
    }
}

// 视图模式枚举
enum ViewMode: String {
    case grid = "grid"
    case card = "card"
} 