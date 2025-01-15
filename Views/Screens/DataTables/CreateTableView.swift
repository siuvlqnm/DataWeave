import SwiftUI
import SwiftData

// MARK: - Field Row View
struct FieldRowView: View {
    let index: Int
    let field: DataField
    let mainColor: Color
    let accentColor: Color
    let isDragging: Bool
    @Binding var editingFieldIndex: Int?  // 改为 Binding
    @Binding var editingFieldName: String
    var onEdit: (Int) -> Void
    var onDelete: () -> Void
    let isTarget: Bool  // 标记是否为拖拽目标位置
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .frame(width: 24)
                .opacity(isDragging ? 0.5 : 1) // 拖拽时降低原位置透明度
            
            Image(systemName: field.type.icon)
                .foregroundColor(field.type.isPro ? .gray : accentColor)
                .frame(width: 24)
            
            if editingFieldIndex == index {
                TextField("字段名称", text: $editingFieldName)
                    .textFieldStyle(.plain)
                    .focused($isFieldFocused)
                    .onChange(of: isFieldFocused) { newValue in
                        if !newValue {  // 失去焦点时保存
                            onEdit(index)
                        }
                    }
                    .onSubmit {  // 按回车键时保存
                        onEdit(index)
                    }
                    .onAppear {
                        isFieldFocused = true
                    }
            } else {
                Text(field.name)
                    .foregroundColor(mainColor)
                    .onTapGesture {
                        editingFieldIndex = index
                        editingFieldName = field.name
                    }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(isDragging ? 0.1 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.1), lineWidth: isDragging ? 2 : 0)
        )
        .offset(y: isTarget ? 6 : 0) // 目标位置显示一个小位移
        .animation(.easeInOut(duration: 0.2), value: isTarget) // 添加动画
    }
}

// MARK: - Field Type Grid View
struct FieldTypeGridView: View {
    let group: (String, [DataField.FieldType])
    let mainColor: Color
    let accentColor: Color
    var onSelect: (DataField.FieldType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(group.0)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(mainColor)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(group.1, id: \.self) { type in
                    Button(action: { onSelect(type) }) {
                        HStack {
                            Image(systemName: type.icon)
                                .foregroundColor(type.isPro ? .gray : accentColor)
                            Text(type.rawValue)
                                .foregroundColor(type.isPro ? .gray : mainColor)
                            Spacer()
                            if type.isPro {
                                Text("PRO")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .disabled(type.isPro)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
}

// 1. 添加可拖拽列表组件
struct DraggableFieldsList: View {
    @Binding var fields: [DataField]
    let mainColor: Color
    let accentColor: Color
    @State private var draggedItem: DataField?
    @State private var dropIndex: Int?
    @Binding var editingFieldIndex: Int?  // 改为 Binding
    @Binding var editingFieldName: String
    
    var body: some View {
        LazyVStack(spacing: 8) { // 减小间距从 12 到 8
            ForEach(Array(fields.enumerated()), id: \.element.id) { index, field in
                FieldRowView(
                    index: index,
                    field: field,
                    mainColor: mainColor,
                    accentColor: accentColor,
                    isDragging: draggedItem?.id == field.id,
                    editingFieldIndex: $editingFieldIndex,
                    editingFieldName: $editingFieldName,
                    onEdit: { handleEdit(index: $0) },
                    onDelete: { handleDelete(at: index) },
                    isTarget: dropIndex == index
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 4) // 减小垂直内边距从 8 到 4
                .background(Color.white)
                .cornerRadius(8)
                .onTapGesture {
                    startEditing(index: index)
                }
                .onDrag {
                    if editingFieldIndex == nil {  // 编辑时禁用拖拽
                        self.draggedItem = field
                        return NSItemProvider(object: "\(index)" as NSString)
                    }
                    return NSItemProvider()
                }
                .onDrop(
                    of: [.text],
                    delegate: CustomDropDelegate(
                        item: field,
                        items: $fields,
                        draggedItem: $draggedItem,
                        dropIndex: $dropIndex
                    )
                )
            }
        }
        .padding(.vertical, 4) // 减小整体垂直内边距从 8 到 4
    }
    
    private func startEditing(index: Int) {
        editingFieldIndex = index
        editingFieldName = fields[index].name
    }
    
    private func handleEdit(index: Int) {
        if (!editingFieldName.isEmpty) {
            fields[index].name = editingFieldName
        }
        editingFieldIndex = nil
        editingFieldName = ""
    }
    
    private func handleDelete(at index: Int) {
        fields.remove(at: index)
    }
}

struct CreateTableView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tableName = ""
    @State private var tableDescription = ""
    @State private var fields: [DataField] = []
    @State private var showAllFields = false
    @State private var editingFieldIndex: Int?
    @State private var editingFieldName: String = ""
    @State private var draggedItem: DataField?
    @State private var dropIndex: Int?
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    // 字段分组
    private let fieldGroups: [(String, [DataField.FieldType])] = [
        ("基础类型", [.text, .richText, .number, .decimal, .boolean]),
        ("日期时间", [.date, .time, .dateTime]),
        // ("选择类型", [.select, .multiSelect]),
        ("媒体类型", [.image, .file]),
        ("联系信息", [.email, .phone, .url]),
        ("高级类型", [.location, .color, .barcode, .qrCode])
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 基本信息卡片
                        VStack(alignment: .leading, spacing: 16) {
                            Text("基本信息")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(mainColor)
                            // 数据表名称还是其他名字，实例名称？或者其他名字，待定
                            VStack(spacing: 12) {
                                TextField("数据表名称", text: $tableName)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                
                                TextField("描述（选填）", text: $tableDescription)
                                    .textFieldStyle(.plain)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                        
                        // 字段列表卡片
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("字段列表")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(mainColor)
                                
                                Text("点击字段名称可编辑")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: { 
                                    withAnimation(.spring(
                                        response: 0.4,     // 调整响应时间
                                        dampingFraction: 0.8,  // 弹性阻尼
                                        blendDuration: 0.2    // 混合持续时间
                                    )) {
                                        showAllFields.toggle()
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("添加字段")
                                    }
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(accentColor.opacity(0.1))
                                    .foregroundColor(accentColor)
                                    .cornerRadius(20)
                                }
                            }
                            
                            if fields.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("点击“添加字段”开始创建")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else {
                                DraggableFieldsList(
                                    fields: $fields,
                                    mainColor: mainColor,
                                    accentColor: accentColor,
                                    editingFieldIndex: $editingFieldIndex,
                                    editingFieldName: $editingFieldName
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                        
                        // 字段选择面板
                        if showAllFields {
                            ForEach(fieldGroups, id: \.0) { group in
                                FieldTypeGridView(
                                    group: group,
                                    mainColor: mainColor,
                                    accentColor: accentColor,
                                    onSelect: { type in
                                        addField(type: type)
                                    }
                                )
                                .transition(
                                    .asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity)
                                            .animation(.spring(
                                                response: 0.4,
                                                dampingFraction: 0.8,
                                                blendDuration: 0.2
                                            )),
                                        removal: .scale(scale: 0.95).combined(with: .opacity)
                                            .animation(.spring(
                                                response: 0.3,
                                                dampingFraction: 1,
                                                blendDuration: 0.1
                                            ))
                                    )
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("新建数据表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(mainColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        createTable()
                    }
                    .disabled(tableName.isEmpty || fields.isEmpty)
                    .foregroundColor(tableName.isEmpty || fields.isEmpty ? .gray : accentColor)
                }
            }
        }
    }
    
    private func addField(type: DataField.FieldType) {
        let defaultName = type.rawValue
        let field = DataField(name: defaultName, type: type)
        fields.append(field)
    }
    
    private func createTable() {
        let table = DataTable(name: tableName, description: tableDescription)
        // 保存时设置排序索引
        fields.enumerated().forEach { index, field in
            field.sortIndex = index
        }
        table.fields = fields
        modelContext.insert(table)
        try? modelContext.save()
        dismiss()
    }
}

// 添加 CustomDropDelegate 实现
struct CustomDropDelegate: DropDelegate {
    let item: DataField
    @Binding var items: [DataField]
    @Binding var draggedItem: DataField?
    @Binding var dropIndex: Int?
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        guard let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id })
        else { return }
        
        dropIndex = toIndex
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        dropIndex = nil
        guard let draggedItem = draggedItem else { return false }
        guard let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id })
        else { return false }
        
        withAnimation {
            if fromIndex != toIndex {
                items.move(fromOffsets: IndexSet(integer: fromIndex),
                          toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
        
        self.draggedItem = nil
        return true
    }
    
    func dropExited(info: DropInfo) {
        dropIndex = nil
    }
}

#Preview {
    CreateTableView()
}
