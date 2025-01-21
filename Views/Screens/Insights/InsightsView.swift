import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DataTable.name) private var tables: [DataTable]
    
    @State private var selectedTable: DataTable?
    @State private var selectedTimeRange = TimeRange.month
    @State private var selectedMetrics: Set<InsightMetric> = [.recordCount]
    @State private var showingExportSheet = false
    
    // 添加颜色定义，与HomeView保持一致
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 添加背景色
                backgroundColor.ignoresSafeArea()
                
                Group {
                    if tables.isEmpty {
                        EmptyInsightsView()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                // 表格选择器
                                TableSelector(tables: tables, selectedTable: $selectedTable)
                                    .padding(.horizontal)
                                
                                if let selectedTable {
                                    LazyVStack(spacing: 16) {
                                        // 分析控制面板
                                        AnalyticsControlPanel(
                                            timeRange: $selectedTimeRange,
                                            selectedMetrics: $selectedMetrics
                                        )
                                        
                                        // 关键指标概览
                                        KeyMetricsGrid(
                                            table: selectedTable,
                                            timeRange: selectedTimeRange
                                        )
                                        
                                        // 趋势分析
                                        TrendAnalysisSection(
                                            table: selectedTable,
                                            timeRange: selectedTimeRange,
                                            metrics: selectedMetrics
                                        )
                                        
                                        // 字段分布分析
                                        FieldDistributionSection(table: selectedTable)
                                        
                                        // 数据质量报告
                                        DataQualitySection(table: selectedTable)
                                    }
                                    .padding(.horizontal)
                                } else {
                                    ContentUnavailableView(
                                        "请选择数据表",
                                        systemImage: "table",
                                        description: Text("选择一个数据表以查看分析洞察")
                                    )
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("数据洞察")
                        .font(.system(size: 22, weight: .bold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTable != nil {
                        Menu {
                            Button(action: { showingExportSheet = true }) {
                                Label("导出报告", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: refreshInsights) {
                                Label("刷新数据", systemImage: "arrow.clockwise")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(mainColor)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                // TODO: 实现导出报告视图
                Text("导出报告")
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func refreshInsights() {
        // TODO: 刷新分析数据
    }
    
    private func exportInsightsReport() {
        showingExportSheet = true
    }
}

// 时间范围枚举
enum TimeRange: String, CaseIterable {
    case day = "今日"
    case week = "本周"
    case month = "本月"
    case year = "今年"
    
    var dateInterval: DateInterval {
        let now = Date()
        switch self {
        case .day:
            return Calendar.current.dateInterval(of: .day, for: now)!
        case .week:
            return Calendar.current.dateInterval(of: .weekOfYear, for: now)!
        case .month:
            return Calendar.current.dateInterval(of: .month, for: now)!
        case .year:
            return Calendar.current.dateInterval(of: .year, for: now)!
        }
    }
}

// 分析指标枚举
enum InsightMetric: String, CaseIterable {
    case recordCount = "记录数"
    case fieldCompleteness = "字段完整度"
    case updateFrequency = "更新频率"
    // 可以根据需要添加更多指标
}

// MARK: - 子视图组件
struct EmptyInsightsView: View {
    var body: some View {
        ContentUnavailableView {
            Label("暂无数据表", systemImage: "chart.bar.xaxis")
        } description: {
            Text("创建数据表后即可查看分析洞察")
        } actions: {
            NavigationLink(destination: Text("创建数据表")) {
                Text("创建数据表")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TableSelector: View {
    let tables: [DataTable]
    @Binding var selectedTable: DataTable?
    private let accentColor = Color(hex: "A020F0")
    
    var body: some View {
        Menu {
            Button(action: { selectedTable = nil }) {
                HStack {
                    Text("请选择数据表")
                    if selectedTable == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            ForEach(tables) { table in
                Button(action: { selectedTable = table }) {
                    HStack {
                        Text(table.name)
                        if selectedTable == table {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Label(
                    selectedTable?.name ?? "选择数据表",
                    systemImage: "table"
                )
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(accentColor.opacity(0.1))
            .foregroundColor(accentColor)
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        InsightsView()
            .modelContainer(previewContainer)
    }
}

// MARK: - Preview Helpers
@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: DataTable.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        // 创建示例数据
        let table = DataTable(name: "示例表", description: "这是一个示例数据表")
        container.mainContext.insert(table)
        
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}() 