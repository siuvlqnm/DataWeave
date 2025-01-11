import SwiftUI
import SwiftData

struct DataTableDetailView: View {
    let table: DataTable
    
    @Environment(\.modelContext) private var modelContext
    @State private var showAddRecord = false
    @State private var searchText = ""
    
    private let mainColor = Color(hex: "1A202C")
    private let accentColor = Color(hex: "A020F0")
    private let backgroundColor = Color(hex: "FAF0E6")
    
    private struct InfoRow: View {
        let icon: String
        let label: String
        let value: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Text(label + "：")
                    .foregroundColor(.secondary)
                
                Text(value)
                    .foregroundColor(Color(hex: "1A202C"))
            }
            .font(.system(size: 14))
        }
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
                    
                    // 字段列表卡片
                    // VStack(alignment: .leading, spacing: 16) {
                    //     HStack(spacing: 8) {
                    //         Image(systemName: "list.bullet.rectangle.fill")
                    //             .foregroundColor(accentColor)
                    //         Text("字段列表")
                    //             .font(.headline)
                    //             .foregroundColor(mainColor)
                    //     }
                        
                    //     ForEach(table.fields) { field in
                    //         HStack {
                    //             Image(systemName: field.type.icon)
                    //                 .foregroundColor(field.type.isPro ? .gray : accentColor)
                    //                 .frame(width: 24)
                                
                    //             VStack(alignment: .leading) {
                    //                 Text(field.name)
                    //                     .foregroundColor(mainColor)
                    //                 Text(field.type.rawValue)
                    //                     .font(.caption)
                    //                     .foregroundColor(.secondary)
                    //             }
                                
                    //             Spacer()
                                
                    //             if field.isRequired {
                    //                 Text("必填")
                    //                     .font(.caption)
                    //                     .padding(.horizontal, 8)
                    //                     .padding(.vertical, 2)
                    //                     .background(Color.red.opacity(0.1))
                    //                     .foregroundColor(.red)
                    //                     .cornerRadius(4)
                    //             }
                    //         }
                    //         .padding()
                    //         .background(Color.gray.opacity(0.05))
                    //         .cornerRadius(8)
                    //     }
                    // }
                    // .padding(16)
                    // .frame(maxWidth: .infinity, alignment: .leading)
                    // .background(
                    //     RoundedRectangle(cornerRadius: 16)
                    //         .fill(Color.white)
                    //         .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    // )
                    // .padding(.horizontal, 16)
                    
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
                        
                        // TODO: 实现数据记录列表
                        Text("暂无数据")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
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
        .sheet(isPresented: $showAddRecord) {
            AddRecordView(table: table)
        }
    }
}

#Preview {
    NavigationView {
        DataTableDetailView(
            table: DataTable(
                name: "测试表",
                description: "这是一个测试表"
            )
        )
    }
} 