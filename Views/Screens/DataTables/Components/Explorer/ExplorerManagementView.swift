import SwiftUI
import SwiftData

struct ExplorerManagementView: View {
    let table: DataTable
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var configManager: ExplorerConfigManager!
    @State private var configs: [ExplorerView] = []
    @State private var tempConfigs: [ExplorerView] = []
    @State private var draggedConfig: ExplorerView?
    @State private var isEditing = false
    @State private var showAddConfig = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // 说明卡片
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(accentColor)
                                Text("拖动调整视图顺序，点击进入视图")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // 配置列表
                            VStack(spacing: 12) {
                                ForEach(tempConfigs) { config in
                                    ConfigRow(
                                        config: config,
                                        isEditing: $isEditing,
                                        onTap: {
                                            if !isEditing {
                                                // 导航到详情视图
                                            }
                                        },
                                        onDelete: { deleteConfig(config) }
                                    )
                                    .onDrag {
                                        self.draggedConfig = config
                                        return NSItemProvider()
                                    }
                                    .onDrop(of: [.text], delegate: ConfigDropDelegate(
                                        item: config,
                                        items: $tempConfigs,
                                        draggedItem: $draggedConfig
                                    ))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
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
                    HStack {
                        if isEditing {
                            Button(action: {
                                showAddConfig = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(accentColor)
                            }
                        }
                        
                        Button(action: {
                            if isEditing {
                                configs = tempConfigs
                                updateConfigIndexes()
                                isEditing = false
                            } else {
                                isEditing = true
                            }
                        }) {
                            Text(isEditing ? "完成" : "编辑")
                                .foregroundColor(accentColor)
                        }
                    }
                }
            }
        }
        .onAppear {
            configManager = ExplorerConfigManager(modelContext: modelContext, table: table)
            configs = configManager.availableConfigs
            tempConfigs = configs
        }
        .sheet(isPresented: $showAddConfig) {
            AddExplorerView(configManager: configManager)
        }
    }
    
    private func updateConfigIndexes() {
        // TODO: 实现排序索引更新
        try? modelContext.save()
    }
    
    private func deleteConfig(_ config: ExplorerView) {
        if let index = tempConfigs.firstIndex(of: config) {
            tempConfigs.remove(at: index)
        }
    }
}

private struct ConfigRow: View {
    let config: ExplorerView
    @Binding var isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private let mainColor = Color(hex: "1A202C")
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 4)
                }
                
                Image(systemName: config.viewMode == ViewMode.grid.rawValue ? "square.grid.2x2" : "square.grid.3x3")
                    .foregroundColor(.gray)
                
                Text(config.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(mainColor)
                
                Spacer()
                
                if isEditing {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 3)
        }
        .buttonStyle(.plain)
    }
}

struct ConfigDropDelegate: DropDelegate {
    let item: ExplorerView
    @Binding var items: [ExplorerView]
    @Binding var draggedItem: ExplorerView?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else { return false }
        
        if let from = items.firstIndex(of: draggedItem),
           let to = items.firstIndex(of: item) {
            if items[to] != items[from] {
                items.move(fromOffsets: IndexSet(integer: from),
                          toOffset: to > from ? to + 1 : to)
            }
            return true
        }
        return false
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        if let from = items.firstIndex(of: draggedItem),
           let to = items.firstIndex(of: item) {
            if items[to] != items[from] {
                items.move(fromOffsets: IndexSet(integer: from),
                          toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// 新增的详情视图
struct ExplorerDetailView: View {
    let table: DataTable
    let config: ExplorerView
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedRecords: Set<UUID> = []
    
    // 查询数据记录
    @Query private var records: [DataRecord]
    
    init(table: DataTable, config: ExplorerView) {
        self.table = table
        self.config = config
        let tableId = table.id
        _records = Query(filter: #Predicate<DataRecord> { record in
            record.table?.id == tableId
        })
    }
    
    var body: some View {
        ZStack {
            Color(hex: "FAF0E6").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("搜索...", text: $searchText)
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .padding()
                
                // 内容区域
                ScrollView {
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
        .navigationTitle(config.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !selectedRecords.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
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
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}