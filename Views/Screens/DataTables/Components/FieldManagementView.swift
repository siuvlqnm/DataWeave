import SwiftUI
import SwiftData

struct FieldManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    @State private var showAddField = false
    @State private var fields: [DataField]
    @State private var draggedField: DataField?
    @State private var selectedField: DataField?
    @State private var isEditing = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable) {
        self.table = table
        _fields = State(initialValue: table.fields.sorted(by: { $0.sortIndex < $1.sortIndex }))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 简化的说明卡片
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(accentColor)
                            Text("拖动调整字段顺序，点击编辑属性")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // 字段列表
                        VStack(spacing: 12) {
                            ForEach(fields) { field in
                                FieldRow(
                                    field: field,
                                    isEditing: $isEditing,
                                    onTap: { selectedField = field },
                                    onDelete: { deleteField(field) }
                                )
                                .onDrag {
                                    draggedField = field
                                    return NSItemProvider()
                                }
                                .onDrop(of: [.text], delegate: DropViewDelegate(item: field, items: $fields, draggedItem: $draggedField))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if isEditing {
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(mainColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing {
                            isEditing = false
                        } else {
                            isEditing = true
                        }
                    }) {
                        Text(isEditing ? "完成" : "编辑")
                            .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isEditing {
                        Button(action: { showAddField = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(accentColor)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddField) {
            AddFieldView(fields: $fields)
        }
        .sheet(item: $selectedField) { field in
            EditFieldView(table: table, field: field)
        }
    }
    
    private func updateFieldIndexes() {
        for (index, field) in fields.enumerated() {
            field.sortIndex = index
        }
        table.fields = fields
        try? modelContext.save()
    }
    
    private func deleteField(_ field: DataField) {
        if let index = fields.firstIndex(of: field) {
            fields.remove(at: index)
            updateFieldIndexes()
        }
    }
}

private struct FieldRow: View {
    let field: DataField
    @Binding var isEditing: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(field.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(mainColor)
                    
                    HStack(spacing: 4) {
                        Image(systemName: field.type.icon)
                            .font(.system(size: 12))
                        Text(field.type.rawValue)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if field.isRequired {
                    Text("必填")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                }
                
                if field.type.isPro {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }
                
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
        .disabled(isEditing)
    }
}

struct DropViewDelegate: DropDelegate {
    let item: DataField
    @Binding var items: [DataField]
    @Binding var draggedItem: DataField?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            
            if items[to] != items[from] {
                items.move(fromOffsets: IndexSet(integer: from),
                          toOffset: to > from ? to + 1 : to)
            }
        }
    }
} 