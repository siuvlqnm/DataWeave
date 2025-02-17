import SwiftUI
import SwiftData

struct FieldManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let table: DataTable
    @State private var showAddField = false
    @State private var fields: [DataField]
    @State private var tempFields: [DataField]
    @State private var draggedField: DataField?
    @State private var selectedField: DataField?
    @State private var isEditing = false
    @State private var allFieldTypes = DataField.FieldType.allCases
    @State private var showAllFields = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    init(table: DataTable) {
        self.table = table
        let sortedFields = table.fields.sorted(by: { $0.sortIndex < $1.sortIndex })
        _fields = State(initialValue: sortedFields)
        _tempFields = State(initialValue: sortedFields)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 现有字段列表
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
                                ForEach(tempFields) { field in
                                    FieldRow(
                                        field: field,
                                        isEditing: $isEditing,
                                        onTap: { selectedField = field },
                                        onDelete: { deleteField(field) }
                                    )
                                    .onDrag {
                                        self.draggedField = field
                                        return NSItemProvider()
                                    }
                                    .onDrop(of: [.text], delegate: DropViewDelegate(
                                        item: field,
                                        items: $tempFields,
                                        draggedItem: $draggedField
                                    ))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                    
                    // 底部所有字段类型列表
                    if isEditing {
                        Divider()
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(allFieldTypes, id: \.self) { fieldType in
                                    Button(action: {
                                        addNewField(type: fieldType)
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: fieldType.icon)
                                                .font(.system(size: 24))
                                            Text(fieldType.rawValue)
                                                .font(.system(size: 12))
                                            if fieldType.isPro {
                                                Text("PRO")
                                                    .font(.system(size: 10))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Color.yellow.opacity(0.2))
                                                    .cornerRadius(4)
                                            }
                                        }
                                        .frame(height: 80)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .foregroundColor(fieldType.isPro ? .gray : mainColor)
                                }
                            }
                            .padding()
                        }
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.05))
                    }
                }
            }
            .navigationTitle("字段管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing {
                            fields = tempFields
                            updateFieldIndexes()
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
        if let index = tempFields.firstIndex(of: field) {
            tempFields.remove(at: index)
        }
    }
    
    private func addNewField(type: DataField.FieldType) {
        let newField = DataField(
            name: "\(type.rawValue)\(tempFields.count + 1)",
            type: type,
            isRequired: false
        )
        tempFields.append(newField)
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
    }
}

struct DropViewDelegate: DropDelegate {
    let item: DataField
    @Binding var items: [DataField]
    @Binding var draggedItem: DataField?
    
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