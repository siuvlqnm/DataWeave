import SwiftUI
import SwiftData

struct CreateTableView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tableName = ""
    @State private var tableDescription = ""
    @State private var fields: [DataField] = []
    @State private var showAllFields = false
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    // 字段分组
    private let fieldGroups: [(String, [DataField.FieldType])] = [
        ("基础类型", [.text, .richText, .number, .decimal, .boolean]),
        ("日期时间", [.date, .time, .dateTime]),
        ("选择类型", [.select, .multiSelect]),
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
                                ForEach(fields) { field in
                                    HStack {
                                        Image(systemName: field.type.icon)
                                            .foregroundColor(field.type.isPro ? .gray : accentColor)
                                            .frame(width: 24)
                                        Text(field.name)
                                            .foregroundColor(mainColor)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            if let index = fields.firstIndex(where: { $0.id == field.id }) {
                                                fields.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(8)
                                }
                                .onMove { from, to in
                                    fields.move(fromOffsets: from, toOffset: to)
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
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(group.0)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(mainColor)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 12) {
                                        ForEach(group.1, id: \.self) { type in
                                            Button(action: { addField(type: type) }) {
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
                                .transition(.move(edge: .top).combined(with: .opacity))
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
        let field = DataField(name: type.rawValue, type: type)
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
