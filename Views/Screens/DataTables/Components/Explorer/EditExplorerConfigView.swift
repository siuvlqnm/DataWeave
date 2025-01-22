import SwiftUI

struct EditExplorerConfigView: View {
    @Environment(\.dismiss) private var dismiss
    let configManager: ExplorerConfigManager
    let config: ExplorerView
    
    @State private var configName: String
    @State private var selectedViewMode: ViewMode
    @State private var columnsCount: Int
    @State private var cardSize: Double
    @State private var selectedFields: Set<String>
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    
    init(configManager: ExplorerConfigManager, config: ExplorerView) {
        self.configManager = configManager
        self.config = config
        
        // 初始化状态
        _configName = State(initialValue: config.name)
        _selectedViewMode = State(initialValue: ViewMode(rawValue: config.viewMode) ?? .grid)
        _columnsCount = State(initialValue: config.columnsCount)
        _cardSize = State(initialValue: config.cardSize)
        _selectedFields = State(initialValue: Set(config.displayFields))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本设置") {
                    TextField("视图名称", text: $configName)
                    
                    Picker("视图模式", selection: $selectedViewMode) {
                        Text("网格视图").tag(ViewMode.grid)
                        Text("卡片视图").tag(ViewMode.card)
                    }
                }
                
                if selectedViewMode == .card {
                    Section("卡片设置") {
                        Stepper("列数: \(columnsCount)", value: $columnsCount, in: 1...6)
                        
                        VStack(alignment: .leading) {
                            Text("卡片大小")
                            Slider(
                                value: $cardSize,
                                in: 150...300,
                                step: 10
                            ) {
                                Text("卡片大小")
                            } minimumValueLabel: {
                                Text("小")
                            } maximumValueLabel: {
                                Text("大")
                            }
                        }
                    }
                    
                    Section("显示字段") {
                        let fields = configManager.table.fields.sorted { $0.sortIndex < $1.sortIndex }
                        ForEach(fields) { field in
                            Toggle(isOn: Binding(
                                get: { selectedFields.contains(field.id.uuidString) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedFields.insert(field.id.uuidString)
                                    } else {
                                        selectedFields.remove(field.id.uuidString)
                                    }
                                }
                            )) {
                                HStack {
                                    Image(systemName: field.type.icon)
                                        .foregroundColor(.gray)
                                    Text(field.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("编辑视图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(configName.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        // 更新配置
        config.name = configName
        config.viewMode = selectedViewMode.rawValue
        config.columnsCount = columnsCount
        config.cardSize = cardSize
        config.displayFields = Array(selectedFields)
        
        configManager.saveCurrentConfig()
        dismiss()
    }
} 