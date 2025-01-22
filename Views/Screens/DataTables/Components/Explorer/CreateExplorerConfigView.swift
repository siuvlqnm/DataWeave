import SwiftUI
import SwiftData

struct CreateExplorerConfigView: View {
    @Environment(\.dismiss) private var dismiss
    let configManager: ExplorerConfigManager
    
    @State private var configName = ""
    @State private var selectedViewMode: ViewMode = .grid
    @State private var columnsCount = 3
    @State private var cardSize: Double = 200
    @State private var selectedFields: Set<String> = []
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    
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
            .navigationTitle("新建视图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        createConfig()
                    }
                    .disabled(configName.isEmpty)
                }
            }
        }
    }
    
    private func createConfig() {
        // 创建新配置
        configManager.createNewConfig(
            name: configName,
            viewMode: selectedViewMode.rawValue,
            columnsCount: columnsCount,
            cardSize: cardSize,
            displayFields: Array(selectedFields)
        )
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    // 预览内容
    CreateExplorerConfigView(
        configManager: ExplorerConfigManager(
            modelContext: ModelContext(try! ModelContainer(for: DataTable.self)),
            table: DataTable(name: "测试表")
        )
    )
} 