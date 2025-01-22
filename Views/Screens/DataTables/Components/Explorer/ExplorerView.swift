import SwiftUI
import SwiftData

enum ExplorerViewMode {
    case grid   // 网格视图
    case card   // 卡片视图
}

struct ExplorerView: View {
    let table: DataTable
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewMode: ExplorerViewMode = .grid
    @State private var searchText = ""
    @State private var selectedRecords: Set<UUID> = []
    @State private var showCreateConfig = false
    @State private var showEditConfig = false
    
    // 颜色定义
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    // 查询数据记录
    @Query private var records: [DataRecord]
    
    @State private var configManager: ExplorerConfigManager!
    
    init(table: DataTable) {
        self.table = table
        let tableId = table.id
        _records = Query(filter: #Predicate<DataRecord> { record in
            record.table?.id == tableId
        })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部工具栏
                    HStack {
                        // 视图模式切换
                        Picker("视图模式", selection: $viewMode) {
                            Image(systemName: "square.grid.2x2")
                                .tag(ExplorerViewMode.grid)
                            Image(systemName: "square.grid.3x3")
                                .tag(ExplorerViewMode.card)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                        
                        Spacer()
                        
                        // 搜索框
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("搜索...", text: $searchText)
                        }
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    
                    // 内容区域
                    ScrollView {
                        if let config = configManager?.currentConfig {
                            if config.viewMode == ViewMode.grid.rawValue {
                                GridExplorerView(
                                    records: records,
                                    fields: table.fields,
                                    selectedRecords: $selectedRecords,
                                    config: config
                                )
                            } else {
                                CardExplorerView(
                                    records: records,
                                    fields: table.fields,
                                    selectedRecords: $selectedRecords,
                                    config: config
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("资源管理器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // 视图操作
                        Button(action: { showCreateConfig = true }) {
                            Label("新建视图", systemImage: "plus")
                        }
                        
                        if let currentConfig = configManager?.currentConfig {
                            Button(action: { showEditConfig = true }) {
                                Label("编辑视图", systemImage: "pencil")
                            }
                            
                            if configManager?.availableConfigs.count ?? 0 > 1 {
                                Button(role: .destructive, action: {
                                    configManager?.deleteConfig(currentConfig)
                                }) {
                                    Label("删除视图", systemImage: "trash")
                                }
                            }
                        }
                        
                        Divider()
                        
                        // 记录操作
                        if !selectedRecords.isEmpty {
                            Button(action: {
                                // TODO: 导出选中记录
                            }) {
                                Label("导出选中项", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(role: .destructive, action: {
                                // TODO: 删除选中记录
                            }) {
                                Label("删除选中项", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            configManager = ExplorerConfigManager(modelContext: modelContext, table: table)
        }
        .sheet(isPresented: $showCreateConfig) {
            CreateExplorerConfigView(configManager: configManager)
        }
        .sheet(isPresented: $showEditConfig) {
            if let currentConfig = configManager?.currentConfig {
                EditExplorerConfigView(
                    configManager: configManager,
                    config: currentConfig
                )
            }
        }
    }
}