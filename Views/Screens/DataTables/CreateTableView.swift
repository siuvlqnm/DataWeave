import SwiftUI
import SwiftData

// MARK: - Field Row View
struct FieldRowView: View {
    let index: Int
    let field: DataField
    let mainColor: Color
    let accentColor: Color
    let isDragging: Bool
    let editingFieldIndex: Int?
    @Binding var editingFieldName: String
    var onEdit: (Int) -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Image(systemName: field.type.icon)
                .foregroundColor(field.type.isPro ? .gray : accentColor)
                .frame(width: 24)
            
            if editingFieldIndex == index {
                TextField("字段名称", text: $editingFieldName)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        onEdit(index)
                    }
                    .onAppear {
                        editingFieldName = field.name
                    }
            } else {
                Text(field.name)
                    .foregroundColor(mainColor)
                    .onTapGesture {
                        onEdit(index)
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
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
                                ForEach(fields.indices, id: \.self) { index in
                                    FieldRowView(
                                        index: index,
                                        field: fields[index],
                                        mainColor: mainColor,
                                        accentColor: accentColor,
                                        isDragging: draggedItem?.id == fields[index].id,
                                        editingFieldIndex: editingFieldIndex,
                                        editingFieldName: $editingFieldName,
                                        onEdit: { idx in
                                            if editingFieldIndex == idx {
                                                fields[idx].name = editingFieldName
                                                editingFieldIndex = nil
                                            } else {
                                                editingFieldIndex = idx
                                            }
                                        },
                                        onDelete: {
                                            fields.remove(at: index)
                                        }
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                if draggedItem == nil {
                                                    draggedItem = fields[index]
                                                }
                                                guard let draggedItem = draggedItem else { return }
                                                
                                                let draggedIndex = Int((value.location.y / 60).rounded())
                                                let validIndex = max(0, min(draggedIndex, fields.count - 1))
                                                
                                                if validIndex != index {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        let fromIndex = fields.firstIndex(where: { $0.id == draggedItem.id }) ?? index
                                                        fields.remove(at: fromIndex)
                                                        fields.insert(draggedItem, at: validIndex)
                                                    }
                                                }
                                            }
                                            .onEnded { _ in
                                                draggedItem = nil
                                            }
                                    )
                                }
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
        table.fields = fields
        modelContext.insert(table)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CreateTableView()
} 
