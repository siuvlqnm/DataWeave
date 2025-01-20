import SwiftUI
import SwiftData

struct DataTableViewManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    @State private var views: [DataTableView]
    @State private var tempViews: [DataTableView]
    @State private var draggedView: DataTableView?
    @State private var selectedView: DataTableView?
    @State private var isEditing = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable) {
        self.table = table
        let sortedViews = table.views.sorted(by: { $0.sortIndex < $1.sortIndex })
        _views = State(initialValue: sortedViews)
        _tempViews = State(initialValue: sortedViews)
    }
    
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
                                Text("拖动调整视图顺序，点击编辑视图")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                            // 视图列表
                            VStack(spacing: 12) {
                                ForEach(tempViews) { view in
                                    ViewRow(
                                        view: view,
                                        isEditing: $isEditing,
                                        onTap: { selectedView = view },
                                        onDelete: { deleteView(view) }
                                    )
                                    .onDrag {
                                        self.draggedView = view
                                        return NSItemProvider()
                                    }
                                    .onDrop(of: [.text], delegate: ViewDropDelegate(
                                        item: view,
                                        items: $tempViews,
                                        draggedItem: $draggedView
                                    ))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("视图管理")
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
                                addNewView()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(accentColor)
                            }
                        }
                        
                        Button(action: {
                            if isEditing {
                                views = tempViews
                                updateViewIndexes()
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
        .sheet(item: $selectedView) { view in
            EditTableViewView(table: table, view: view)
        }
    }
    
    private func updateViewIndexes() {
        for (index, view) in views.enumerated() {
            view.sortIndex = index
        }
        table.views = views
        try? modelContext.save()
    }
    
    private func deleteView(_ view: DataTableView) {
        if let index = tempViews.firstIndex(of: view) {
            tempViews.remove(at: index)
        }
    }
    
    private func addNewView() {
        let newView = DataTableView(
            name: "新视图\(tempViews.count + 1)",
            sortIndex: tempViews.count
        )
        tempViews.append(newView)
    }
}

private struct ViewRow: View {
    let view: DataTableView
    @Binding var isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private let mainColor = Color(hex: "1A202C")
    
    var body: some View {
        Button(action: {
            if !isEditing {
                onTap()
            }
        }) {
            HStack {
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 4)
                }
                
                Text(view.name)
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

struct ViewDropDelegate: DropDelegate {
    let item: DataTableView
    @Binding var items: [DataTableView]
    @Binding var draggedItem: DataTableView?
    
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