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
    
    private var filteredRecords: [DataRecord] {
        if searchText.isEmpty {
            return records
        }
        
        let filtered = records.filter { record in
            record.values.contains { $0.value.localizedCaseInsensitiveContains(searchText) }
        }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Button(action: {}) {
                    //     Label("选择", systemImage: "checkmark.circle")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("排序", systemImage: "arrow.up.arrow.down")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("索引", systemImage: "doc.text.magnifyingglass")
                    // }
                    
                    Button(action: { showFieldManagement = true }) {
                        Label("字段", systemImage: "list.bullet")
                    }
                    
                    // Button(action: {}) {
                    //     Label("列表", systemImage: "list.dash")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("摘要", systemImage: "minus.circle")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("新建视图", systemImage: "plus.circle")
                    // }
                    
                    Button(action: {
                        // Show view management sheet
                        showViewManagement = true
                    }) {
                        Label("视图", systemImage: "eye")
                    }
                    
                    // Button(action: {}) {
                    //     Label("浏览", systemImage: "binoculars")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("打印", systemImage: "printer")
                    // }
                    
                    // Button(action: {}) {
                    //     Label("编辑", systemImage: "square.and.pencil")
                    // }
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
// struct DataTableDetailView: View {
//     let table: DataTable

//     @Environment(\.modelContext) private var modelContext
//     @State private var showAddRecord = false
//     @State private var searchText = ""
//     @State private var navigationPath = NavigationPath()
//     @State private var showFieldManagement = false

//     @Query(sort: [SortDescriptor(\DataRecord.createdAt)]) var records: [DataRecord]

//     private let mainColor = Color(hex: "1A202C")
//     private let accentColor = Color(hex: "A020F0")
//     private let backgroundColor = Color(hex: "FAF0E6")

//     init(table: DataTable) {
//         self.table = table
//         let tableId = table.id
//         _records = Query(filter: #Predicate<DataRecord> { record in
//             record.table?.id == tableId
//         }, sort: [SortDescriptor(\DataRecord.createdAt)])
//     }
    
//     private var filteredRecords: [DataRecord] {
//         if searchText.isEmpty {
//             return records
//         }
        
//         let filtered = records.filter { record in
//             record.values.contains { $0.value.localizedCaseInsensitiveContains(searchText) }
//         }
//         return filtered
//     }
    
//     var body: some View {
//         ZStack {
//             backgroundColor.ignoresSafeArea()
            
//             ScrollView {
//                 LazyVStack(spacing: 12) {
//                     ForEach(filteredRecords) { record in
//                         NavigationLink(value: record) {
//                             RecordListRow(record: record, fields: table.fields ?? [])
//                         }
//                         .buttonStyle(.plain)
//                     }
//                 }
//                 .padding()
//             }
//             .navigationTitle(table.name)
//             .navigationBarTitleDisplayMode(.inline)
//             .navigationDestination(for: DataRecord.self) { record in
//                 RecordDetailView(record: record)
//             }
//             .searchable(text: $searchText)
//             .toolbar {
//                 ToolbarItem(placement: .navigationBarTrailing) {
//                     Menu {
//                         // Button(action: {}) {
//                         //     Label("选择", systemImage: "checkmark.circle")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("排序", systemImage: "arrow.up.arrow.down")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("索引", systemImage: "doc.text.magnifyingglass")
//                         // }
                        
//                         Button(action: { showFieldManagement = true }) {
//                             Label("字段", systemImage: "list.bullet")
//                         }
                        
//                         // Button(action: {}) {
//                         //     Label("列表", systemImage: "list.dash")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("摘要", systemImage: "minus.circle")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("新建视图", systemImage: "plus.circle")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("视图", systemImage: "eye")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("浏览", systemImage: "binoculars")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("打印", systemImage: "printer")
//                         // }
                        
//                         // Button(action: {}) {
//                         //     Label("编辑", systemImage: "square.and.pencil")
//                         // }
//                     } label: {
//                         Image(systemName: "ellipsis.circle")
//                     }
//                 }
//             }
//         }
//     }
// }

// #Preview {
//     DataTableDetailView(
//         table: DataTable(
//             name: "测试表",
//             description: "这是一个测试表"
//         )
//     )
// }

// import SwiftUI
// import SwiftData

// struct DataTableDetailView: View {
//     let table: DataTable

//     @Environment(\.modelContext) private var modelContext
//     @State private var showAddRecord = false
//     @State private var searchText = ""
//     @State private var navigationPath = NavigationPath()
//     @State private var showFieldManagement = false

//     @Query(sort: [SortDescriptor(\DataRecord.createdAt)]) var records: [DataRecord]

//     private let mainColor = Color(hex: "1A202C")
//     private let accentColor = Color(hex: "A020F0")
//     private let backgroundColor = Color(hex: "FAF0E6")

//     init(table: DataTable) {
//         self.table = table
//         print("Initializing DataTableDetailView for table: \(table.name), ID: \(String(describing: table.id))")

//         let tableId = table.id
//         _records = Query(filter: #Predicate<DataRecord> { record in
//             record.table?.id == tableId
//         }, sort: [SortDescriptor(\DataRecord.createdAt)])
//     }
    
//     private var filteredRecords: [DataRecord] {
//         print("Total records count: \(records.count)")
        
//         if searchText.isEmpty {
//             return records
//         }
        
//         let filtered = records.filter { record in
//             record.values.contains { $0.value.localizedCaseInsensitiveContains(searchText) }
//         }
//         print("Filtered records count: \(filtered.count)")
//         return filtered
//     }
    
//     var body: some View {
//         ZStack {
//             backgroundColor.ignoresSafeArea()
            
//             ScrollView {
//                 VStack(spacing: 20) {
//                     // 基本信息卡片
//                     VStack(alignment: .leading, spacing: 12) {
//                         HStack(spacing: 8) {
//                             Image(systemName: "info.circle.fill")
//                                 .foregroundColor(accentColor)
//                             Text("基本信息")
//                                 .font(.headline)
//                                 .foregroundColor(mainColor)
//                         }
                        
//                         VStack(alignment: .leading, spacing: 8) {
//                             InfoRow(icon: "tag.fill", label: "表名", value: table.name)
                            
//                             if let description = table.tableDescription {
//                                 InfoRow(icon: "text.alignleft", label: "描述", value: description)
//                             }
                            
//                             InfoRow(icon: "clock.fill", label: "创建时间", value: table.createdAt.formatted())
//                         }
//                     }
//                     .padding(12)
//                     .frame(maxWidth: .infinity, alignment: .leading)
//                     .background(
//                         RoundedRectangle(cornerRadius: 16)
//                             .fill(Color.white)
//                             .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//                     )
//                     .padding(.horizontal, 16)
                    
//                     // 数据记录卡片
//                     VStack(alignment: .leading, spacing: 12) {
//                         HStack {
//                             Text("数据记录")
//                                 .font(.system(size: 16, weight: .semibold))
//                                 .foregroundColor(mainColor)
                            
//                             Spacer()
                            
//                             Button(action: { showAddRecord = true }) {
//                                 HStack(spacing: 4) {
//                                     Image(systemName: "plus.circle.fill")
//                                     Text("添加记录")
//                                 }
//                                 .font(.system(size: 14))
//                                 .padding(.horizontal, 12)
//                                 .padding(.vertical, 6)
//                                 .background(accentColor.opacity(0.1))
//                                 .foregroundColor(accentColor)
//                                 .cornerRadius(20)
//                             }
//                         }
                        
//                         TextField("搜索记录...", text: $searchText)
//                             .textFieldStyle(RoundedBorderTextFieldStyle())
//                             .padding(.vertical, 8)
                        
//                         if records.isEmpty {
//                             Text("暂无数据")
//                                 .font(.system(size: 14))
//                                 .foregroundColor(.secondary)
//                                 .frame(maxWidth: .infinity, alignment: .center)
//                                 .padding(.vertical, 40)
//                         } else {
//                             LazyVStack(spacing: 0) {
//                                 ForEach(filteredRecords) { record in
//                                     NavigationLink(destination: RecordDetailView(record: record)) {
//                                         RecordRow(record: record)
//                                     }
//                                     .buttonStyle(.plain)
//                                 }
//                             }
//                             .background(Color.white)
//                         }
//                     }
//                     .padding()
//                     .background(Color.white)
//                     .cornerRadius(16)
//                     .shadow(color: Color.black.opacity(0.05), radius: 10)
//                 }
//                 .padding()
//             }
//         }
//         .navigationTitle(table.name)
//         .navigationBarTitleDisplayMode(.inline)
//         .navigationDestination(for: DataRecord.self) { record in
//             RecordDetailView(record: record)
//         }
//         .sheet(isPresented: $showAddRecord) {
//             AddRecordView(table: table)
//         }
//         .sheet(isPresented: $showFieldManagement) {
//             FieldManagementView(table: table)
//         }
//         .toolbar {
//             ToolbarItem(placement: .navigationBarTrailing) {
//                 Menu {
//                     Button(action: {}) {
//                         Label("选择", systemImage: "checkmark.circle")
//                     }
                    
//                     Button(action: {}) {
//                         Label("排序", systemImage: "arrow.up.arrow.down")
//                     }
                    
//                     Button(action: {}) {
//                         Label("索引", systemImage: "doc.text.magnifyingglass")
//                     }
                    
//                     Button(action: { showFieldManagement = true }) {
//                         Label("字段", systemImage: "list.bullet")
//                     }
                    
//                     Button(action: {}) {
//                         Label("列表", systemImage: "list.dash")
//                     }
                    
//                     Button(action: {}) {
//                         Label("摘要", systemImage: "minus.circle")
//                     }
                    
//                     Button(action: {}) {
//                         Label("新建视图", systemImage: "plus.circle")
//                     }
                    
//                     Button(action: {}) {
//                         Label("视图", systemImage: "eye")
//                     }
                    
//                     Button(action: {}) {
//                         Label("浏览", systemImage: "binoculars")
//                     }
                    
//                     Button(action: {}) {
//                         Label("打印", systemImage: "printer")
//                     }
                    
//                     Button(action: {}) {
//                         Label("编辑", systemImage: "square.and.pencil")
//                     }
//                 } label: {
//                     Image(systemName: "ellipsis.circle")
//                 }
//             }
//         }
//     }
// }

// #Preview {
//     DataTableDetailView(
//         table: DataTable(
//             name: "测试表",
//             description: "这是一个测试表"
//         )
//     )
// }

