import SwiftUI
import SwiftData

struct DataTablesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tables: [DataTable]
    
    @State private var searchText = ""
    @State private var showCreateTable = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    var filteredTables: [DataTable] {
        if searchText.isEmpty {
            return tables
        }
        return tables.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {  // 替换 NavigationView
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 搜索栏
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("搜索数据表", text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                        
                        // 数据表列表
                        ForEach(filteredTables) { table in
                            DataTableCards(table: table)
                        }
                        
                        // 空状态提示
                        if tables.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "table")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("还没有数据表")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Button(action: { showCreateTable = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("新建数据表")
                                    }
                                    .font(.system(size: 16))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                }
                            }
                            .padding(.top, 100)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("数据表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateTable = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreateTable) {
            CreateTableView()
        }
    }
}

// 数据表卡片组件
struct DataTableCards: View {
    let table: DataTable
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        NavigationLink(destination: DataTableDetailView(table: table)) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题行
                HStack {
                    Text(table.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "1A202C"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                // 描述
                if let description = table.tableDescription {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // 信息行
                HStack(spacing: 16) {
                    // 字段数量
                    Label("\(table.fields.count) 个字段", systemImage: "list.bullet")
                    
                    // 创建时间
                    Label(formatDate(table.createdAt), systemImage: "clock")
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
        }
        .buttonStyle(.plain)  // 添加按钮样式
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DataTable.self, configurations: config)
    
    // Add sample data
    let sampleTable = DataTable(name: "测试数据表", description: "这是一个测试数据表")
    container.mainContext.insert(sampleTable)
    
    return DataTablesView()
        .modelContainer(container)

    // DataTablesView()
}