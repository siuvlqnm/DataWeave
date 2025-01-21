extension ViewFilter {
    // enum FilterOperation: String, CaseIterable {
    //     case equals = "等于"
    //     case notEquals = "不等于"
    //     case contains = "包含"
    //     case notContains = "不包含"
    //     case startsWith = "开头是"
    //     case endsWith = "结尾是"
    //     case isEmpty = "为空"
    //     case isNotEmpty = "不为空"
    //     case greaterThan = "大于"
    //     case lessThan = "小于"
    // }
    
    func matches(value: String?) -> Bool {
        guard let value = value else {
            return operation == .isEmpty
        }
        
        switch operation {
        case .equals:
            return value == self.value
        case .notEquals:
            return value != self.value
        case .contains:
            return value.contains(self.value)
        case .notContains:
            return !value.contains(self.value)
        case .startsWith:
            return value.hasPrefix(self.value)
        case .endsWith:
            return value.hasSuffix(self.value)
        case .isEmpty:
            return value.isEmpty
        case .isNotEmpty:
            return !value.isEmpty
        case .greaterThan:
            return value > self.value
        case .lessThan:
            return value < self.value
        }
    }
} 