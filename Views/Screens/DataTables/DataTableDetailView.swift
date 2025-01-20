import SwiftUI
import SwiftData

struct DataTableDetailView: View {
    let table: DataTable

    @Environment(\.modelContext) private var modelContext
    @State private var showAddRecord = false
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()
    @State private var showFieldManagement = false
    @State private var showViewManagement = false
    @State private var showAddSort = false
    @State private var sortOrders: [ViewSortOrder] = []

    @Query(sort: [SortDescriptor(\DataRecord.createdAt)]) var records: [DataRecord]

    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")

    init(table: DataTable) {
        self.table = table
        let tableId = table.id
        _records = Query(filter: #Predicate<DataRecord> { record in
            record.table?.id == tableId
        }, sort: [SortDescriptor(\DataRecord.createdAt)])
    }
    
    private var sortedAndFilteredRecords: [DataRecord] {
        var result = records
        
        // 应用搜索过滤
        if !searchText.isEmpty {
            result = result.filter { record in
                record.values.values.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // 应用排序
        if !sortOrders.isEmpty {
            result = result.sorted { (record1: DataRecord, record2: DataRecord) -> Bool in
                for sortOrder in sortOrders {
                    // 处理系统字段
                    switch sortOrder.fieldId {
                    case "creation_date":
                        if record1.createdAt != record2.createdAt {
                            return sortOrder.ascending ? record1.createdAt < record2.createdAt : record1.createdAt > record2.createdAt
                        }
                    case "modified_date":
                        if record1.updatedAt != record2.updatedAt {
                            return sortOrder.ascending ? record1.updatedAt < record2.updatedAt : record1.updatedAt > record2.updatedAt
                        }
                    default:
                        // 处理自定义字段
                        if let fieldUUID = UUID(uuidString: sortOrder.fieldId),
                           let field1 = record1.values[fieldUUID],
                           let field2 = record2.values[fieldUUID],
                           field1 != field2 {
                            return sortOrder.ascending ? field1 < field2 : field1 > field2
                        }
                    }
                }
                // 如果所有排序字段都相等，保持原有顺序
                return false
            }
        }
        
        return result
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
                                ForEach(sortedAndFilteredRecords) { record in
                                    NavigationLink(destination: RecordDetailView(record: record)) {
                                        RecordListRow(record: record, fields: table.fields)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
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
        .navigationDestination(for: DataRecord.self) { record in
            RecordDetailView(record: record)
        }
        .sheet(isPresented: $showAddRecord) {
            AddRecordView(table: table)
        }
        .sheet(isPresented: $showFieldManagement) {
            FieldManagementView(table: table)
        }
        .sheet(isPresented: $showViewManagement) {
            DataTableViewManagementView(table: table)
        }
        .sheet(isPresented: $showAddSort) {
            AddSortView(table: table) { newSort in
                sortOrders.append(newSort)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showAddSort = true }) {
                        Label("排序", systemImage: "arrow.up.arrow.down")
                    }
                    
                    Button(action: { showFieldManagement = true }) {
                        Label("字段", systemImage: "list.bullet")
                    }
                    
                    Button(action: {
                        // Show view management sheet
                        showViewManagement = true
                    }) {
                        Label("视图", systemImage: "eye")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

#Preview {
    DataTableDetailView(
        table: DataTable(
            name: "测试表",
            description: "这是一个测试表"
        )
    )
}

