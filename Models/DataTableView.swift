import Foundation
import SwiftData

@Model
class DataTableView {
    var id: String
    var name: String
    var sortIndex: Int
    var filters: [ViewFilter]
    var sortOrders: [ViewSortOrder]
    var hiddenFields: [String] // 存储被隐藏字段的ID
    
    init(name: String, sortIndex: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.sortIndex = sortIndex
        self.filters = []
        self.sortOrders = []
        self.hiddenFields = []
    }
}

@Model
class ViewFilter {
    var id: String
    var fieldId: String
    var operation: FilterOperation
    var value: String
    var viewName: String
    
    init(fieldId: String, operation: FilterOperation, value: String, viewName: String = "新视图") {
        self.id = UUID().uuidString
        self.fieldId = fieldId
        self.operation = operation
        self.value = value
        self.viewName = viewName
    }
    
    enum FilterOperation: String, Codable, CaseIterable {
        case equals = "等于"
        case notEquals = "不等于"
        case contains = "包含"
        case notContains = "不包含"
        case startsWith = "开头是"
        case endsWith = "结尾是"
        case isEmpty = "为空"
        case isNotEmpty = "不为空"
        case greaterThan = "大于"
        case lessThan = "小于"
    }
}

@Model
class ViewSortOrder {
    var id: String
    var fieldId: String
    var ascending: Bool
    var index: Int
    
    init(fieldId: String, ascending: Bool = true, index: Int) {
        self.id = UUID().uuidString
        self.fieldId = fieldId
        self.ascending = ascending
        self.index = index
    }
} 