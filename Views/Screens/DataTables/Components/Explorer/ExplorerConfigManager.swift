import SwiftUI
import SwiftData

@Observable
class ExplorerConfigManager {
    private var modelContext: ModelContext
    private(set) var table: DataTable
    
    @ObservationIgnored private(set) var currentConfig: ExplorerViewConfig
    @ObservationIgnored private(set) var availableConfigs: [ExplorerViewConfig] = []
    
    init(modelContext: ModelContext, table: DataTable) {
        self.modelContext = modelContext
        self.table = table
        
        // 获取表的 ID 字符串
        let tableIdString = table.id.uuidString
        
        // 加载该表的所有视图配置
        let descriptor = FetchDescriptor<ExplorerViewConfig>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        do {
            // 先获取所有配置
            let allConfigs = try modelContext.fetch(descriptor)
            // 然后在内存中过滤
            availableConfigs = allConfigs.filter { $0.tableId == tableIdString }
            
            // 如果没有配置，创建默认配置
            if availableConfigs.isEmpty {
                let defaultConfig = ExplorerViewConfig(tableId: tableIdString)
                modelContext.insert(defaultConfig)
                currentConfig = defaultConfig
                availableConfigs = [defaultConfig]
            } else {
                currentConfig = availableConfigs[0]
            }
        } catch {
            print("Error fetching explorer configs: \(error)")
            // 创建默认配置
            let defaultConfig = ExplorerViewConfig(tableId: tableIdString)
            modelContext.insert(defaultConfig)
            currentConfig = defaultConfig
            availableConfigs = [defaultConfig]
        }
    }
    
    // 保存当前配置
    func saveCurrentConfig() {
        currentConfig.updatedAt = Date()
        try? modelContext.save()
    }
    
    // 创建新配置
    func createNewConfig(
        name: String,
        viewMode: String = "grid",
        columnsCount: Int = 3,
        cardSize: Double = 200,
        displayFields: [String] = []
    ) {
        let newConfig = ExplorerViewConfig(
            tableId: table.id.uuidString,
            name: name,
            viewMode: viewMode,
            columnsCount: columnsCount,
            cardSize: cardSize
        )
        newConfig.displayFields = displayFields
        modelContext.insert(newConfig)
        availableConfigs.append(newConfig)
        currentConfig = newConfig
        try? modelContext.save()
    }
    
    // 删除配置
    func deleteConfig(_ config: ExplorerViewConfig) {
        guard availableConfigs.count > 1 else { return }
        modelContext.delete(config)
        availableConfigs.removeAll { $0.id == config.id }
        if currentConfig.id == config.id {
            currentConfig = availableConfigs[0]
        }
        try? modelContext.save()
    }
    
    // 更新网格视图配置
    func updateGridConfig(columnWidths: [String: Double], columnOrder: [String]) {
        currentConfig.columnWidths = columnWidths
        currentConfig.columnOrder = columnOrder
        saveCurrentConfig()
    }
    
    // 更新卡片视图配置
    func updateCardConfig(columnsCount: Int, cardSize: Double, displayFields: [String]) {
        currentConfig.columnsCount = columnsCount
        currentConfig.cardSize = cardSize
        currentConfig.displayFields = displayFields
        saveCurrentConfig()
    }
    
    // 更新排序配置
    func updateSortConfig(fieldId: String?, ascending: Bool) {
        currentConfig.sortField = fieldId
        currentConfig.sortAscending = ascending
        saveCurrentConfig()
    }
    
    // 添加过滤规则
    func addFilterRule(fieldId: String, operation: String, value: String) {
        let rule = FilterRule(fieldId: fieldId, operation: operation, value: value)
        currentConfig.filterRules.append(rule)
        saveCurrentConfig()
    }
    
    // 删除过滤规则
    func removeFilterRule(_ rule: FilterRule) {
        currentConfig.filterRules.removeAll { $0.id == rule.id }
        saveCurrentConfig()
    }
} 