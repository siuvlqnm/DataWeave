import SwiftUI
import SwiftData

struct EditTableViewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    let view: DataTableView
    @State private var viewName: String
    @State private var selectedTab = 0
    @State private var showAddFilter = false
    @State private var showAddSort = false
    @State private var hiddenFields: Set<String>
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable, view: DataTableView) {
        self.table = table
        self.view = view
        _viewName = State(initialValue: view.name)
        _hiddenFields = State(initialValue: Set(view.hiddenFields))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部分段控制器
                    Picker("", selection: $selectedTab) {
                        Text("基本信息").tag(0)
                        Text("过滤器").tag(1)
                        Text("排序").tag(2)
                        Text("显示字段").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        // 基本信息标签页
                        basicInfoView
                            .tag(0)
                        
                        // 过滤器标签页
                        filterView
                            .tag(1)
                        
                        // 排序标签页
                        sortView
                            .tag(2)
                        
                        // 显示字段标签页
                        fieldsView
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("编辑视图")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddFilter) {
                AddFilterView(table: table, onAdd: addFilter)
            }
            .sheet(isPresented: $showAddSort) {
                AddSortView(table: table, onAdd: addSort)
            }
        }
    }
    
    private var basicInfoView: some View {
        Form {
            Section("基本信息") {
                TextField("视图名称", text: $viewName)
            }
        }
    }
    
    private var filterView: some View {
        List {
            ForEach(view.filters) { filter in
                FilterRow(filter: filter, table: table)
            }
            .onDelete(perform: deleteFilter)
            
            Button(action: { showAddFilter = true }) {
                Label("添加过滤条件", systemImage: "plus.circle")
            }
        }
    }
    
    private var sortView: some View {
        List {
            ForEach(view.sortOrders) { sort in
                SortRow(sort: sort, table: table)
            }
            .onDelete(perform: deleteSort)
            .onMove(perform: moveSort)
            
            Button(action: { showAddSort = true }) {
                Label("添加排序规则", systemImage: "plus.circle")
            }
        }
    }
    
    private var fieldsView: some View {
        List {
            ForEach(table.fields) { field in
                Toggle(field.name, isOn: .init(
                    get: { !hiddenFields.contains(field.id.uuidString) },
                    set: { isVisible in
                        if isVisible {
                            hiddenFields.remove(field.id.uuidString)
                        } else {
                            hiddenFields.insert(field.id.uuidString)
                        }
                    }
                ))
            }
        }
    }
    
    private func saveChanges() {
        view.name = viewName
        view.hiddenFields = Array(hiddenFields)
        try? modelContext.save()
    }
    
    private func addFilter(_ filter: ViewFilter) {
        view.filters.append(filter)
    }
    
    private func deleteFilter(at offsets: IndexSet) {
        view.filters.remove(atOffsets: offsets)
    }
    
    private func addSort(_ sort: ViewSortOrder) {
        view.sortOrders.append(sort)
    }
    
    private func deleteSort(at offsets: IndexSet) {
        view.sortOrders.remove(atOffsets: offsets)
    }
    
    private func moveSort(from source: IndexSet, to destination: Int) {
        view.sortOrders.move(fromOffsets: source, toOffset: destination)
        // 更新排序索引
        for (index, sort) in view.sortOrders.enumerated() {
            sort.index = index
        }
    }
}