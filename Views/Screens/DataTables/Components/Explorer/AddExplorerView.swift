import SwiftUI
import SwiftData

struct AddExplorerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    let existingConfig: ExplorerView?
    let onAdd: (ExplorerView) -> Void
    
    @State private var configName: String
    @State private var selectedViewMode: ViewMode = .grid
    @State private var columnsCount = 3
    @State private var cardSize: Double = 200
    @State private var selectedFields: Set<String> = []
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable, existingConfig: ExplorerView? = nil, onAdd: @escaping (ExplorerView) -> Void) {
        self.table = table
        self.existingConfig = existingConfig
        self.onAdd = onAdd
        
        // 初始化状态
        _configName = State(initialValue: existingConfig?.name ?? "")
        if let config = existingConfig {
            _selectedViewMode = State(initialValue: ViewMode(rawValue: config.viewMode) ?? .grid)
            _columnsCount = State(initialValue: config.columnsCount)
            _cardSize = State(initialValue: config.cardSize)
            _selectedFields = State(initialValue: Set(config.displayFields))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    List {
                        Section {
                            TextField("视图名称", text: $configName)
                                .foregroundColor(mainColor)
                        }
                        
                        Section {
                            Picker("视图模式", selection: $selectedViewMode) {
                                Text("网格视图").tag(ViewMode.grid)
                                Text("卡片视图").tag(ViewMode.card)
                            }
                            .foregroundColor(mainColor)
                        }
                        
                        if selectedViewMode == .card {
                            Section("卡片设置") {
                                Stepper("列数: \(columnsCount)", value: $columnsCount, in: 1...6)
                                    .foregroundColor(mainColor)
                                
                                VStack(alignment: .leading) {
                                    Text("卡片大小")
                                        .foregroundColor(mainColor)
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
                                let fields = table.fields.sorted { $0.sortIndex < $1.sortIndex }
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
                                                .foregroundColor(mainColor)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // 保存按钮
                    Button(action: createConfig) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                            Text("保存视图")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(configName.isEmpty ? Color.gray : accentColor)
                        .cornerRadius(8)
                    }
                    .disabled(configName.isEmpty)
                    .padding()
                }
            }
            .navigationTitle("新建视图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
    }
    
    private func createConfig() {
        let config = ExplorerView(
            tableId: table.id.uuidString,
            name: configName,
            viewMode: selectedViewMode.rawValue,
            columnsCount: columnsCount,
            cardSize: cardSize
        )
        config.displayFields = Array(selectedFields)
        
        onAdd(config)
        dismiss()
    }
}

#Preview {
    AddExplorerView(
        table: DataTable(name: "测试表"),
        onAdd: { _ in }
    )
} 