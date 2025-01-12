import SwiftUI
import SwiftData

struct DataTableDetailView: View {
    let table: DataTable

    @Environment(\.modelContext) private var modelContext
    @State private var showAddRecord = false
    @State private var searchText = ""

    @Query(sort: [SortDescriptor(\DataRecord.createdAt)]) var records: [DataRecord] // 修改了 sort 的写法

    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")

    init(table: DataTable) {
        self.table = table
        print("Initializing DataTableDetailView for table: \(table.name), ID: \(String(describing: table.id))")

        // 捕获 table.id 的值
        let tableId = table.id

        _records = Query(filter: #Predicate<DataRecord> { record in
            record.table?.id == tableId
        }, sort: [SortDescriptor(\DataRecord.createdAt)]) // 显式使用 SortDescriptor
    }
    
    private struct InfoRow: View {
        let icon: String
        let label: String
        let value: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Text(label + "：")
                    .foregroundColor(.secondary)
                
                Text(value)
                    .foregroundColor(Color(hex: "1A202C"))
            }
            .font(.system(size: 14))
        }
    }
    
    private struct RecordRow: View {
        let record: DataRecord
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Record ID: \(record.id)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ForEach(record.values.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    HStack(spacing: 8) {
                        Text(String(describing: key))
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                            .frame(width: 80, alignment: .leading)
                        
                        Text(value)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Created: \(record.createdAt.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            .onAppear {
                print("Displaying record: \(record.id), Table: \(record.table?.name ?? "nil")")
            }
        }
    }
    
    private var filteredRecords: [DataRecord] {
        print("Total records count: \(records.count)")
        
        if searchText.isEmpty {
            return records
        }
        
        let filtered = records.filter { record in
            record.values.contains { $0.value.localizedCaseInsensitiveContains(searchText) }
        }
        print("Filtered records count: \(filtered.count)")
        return filtered
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 基本信息卡片
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(accentColor)
                            Text("基本信息")
                                .font(.headline)
                                .foregroundColor(mainColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "tag.fill", label: "表名", value: table.name)
                            
                            if let description = table.tableDescription {
                                InfoRow(icon: "text.alignleft", label: "描述", value: description)
                            }
                            
                            InfoRow(icon: "clock.fill", label: "创建时间", value: table.createdAt.formatted())
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    
                    // 数据记录卡片
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("数据记录")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(mainColor)
                            
                            Spacer()
                            
                            Button(action: { showAddRecord = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("添加记录")
                                }
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(accentColor.opacity(0.1))
                                .foregroundColor(accentColor)
                                .cornerRadius(20)
                            }
                        }
                        
                        TextField("搜索记录...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 8)
                        
                        if records.isEmpty {
                            Text("暂无数据")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredRecords) { record in
                                    RecordRow(record: record)
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                }
                .padding()
            }
        }
        .navigationTitle(table.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddRecord) {
            AddRecordView(table: table)
        }
    }
}

#Preview {
    NavigationView {
        DataTableDetailView(
            table: DataTable(
                name: "测试表",
                description: "这是一个测试表"
            )
        )
    }
} 