import SwiftUI
import SwiftData

struct SortManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    let currentView: DataTableView
    @State private var showAddSort = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    if currentView.sortOrders.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("暂无排序规则")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(currentView.sortOrders) { sort in
                                HStack {
                                    Image(systemName: sort.ascending ? "arrow.up" : "arrow.down")
                                        .foregroundColor(accentColor)
                                    
                                    Text(getFieldName(for: sort.fieldId))
                                        .foregroundColor(mainColor)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        deleteSort(sort)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                    
                    // 添加排序按钮
                    Button(action: {
                        showAddSort = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("添加排序")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(accentColor)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("排序管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
            }
            .sheet(isPresented: $showAddSort) {
                AddSortView(table: table) { newSort in
                    addSort(newSort)
                }
            }
        }
    }
    
    private func getFieldName(for fieldId: String) -> String {
        // 处理系统字段
        switch fieldId {
        case "creation_date":
            return "创建日期"
        case "modified_date":
            return "修改日期"
        default:
            // 处理自定义字段
            if let uuid = UUID(uuidString: fieldId),
               let field = table.fields.first(where: { $0.id == uuid }) {
                return field.name
            }
            return "未知字段"
        }
    }
    
    private func deleteSort(_ sort: ViewSortOrder) {
        if let index = currentView.sortOrders.firstIndex(where: { $0.id == sort.id }) {
            currentView.sortOrders.remove(at: index)
            try? modelContext.save()
        }
    }
    
    private func addSort(_ sort: ViewSortOrder) {
        currentView.sortOrders.append(sort)
        try? modelContext.save()
    }
} 