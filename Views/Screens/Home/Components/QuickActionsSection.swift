import SwiftUI

struct QuickActionsSection: View {
    @State private var showCreateTable = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "快捷操作")
            
            LazyVGrid(columns: columns, spacing: 16) {
                QuickActionButton(
                    icon: "plus.circle.fill",
                    title: "新建数据表",
                    color: .purple
                ) {
                    showCreateTable = true
                }
                
                QuickActionButton(
                    icon: "square.and.arrow.up.fill",
                    title: "导入数据",
                    color: .blue
                ) {
                    // TODO: 导入数据功能
                }
                
                QuickActionButton(
                    icon: "wand.and.stars",
                    title: "数据分析",
                    color: .orange
                ) {
                    // TODO: 数据分析功能
                }
                
                QuickActionButton(
                    icon: "bolt.horizontal.fill",
                    title: "自动化",
                    color: .green
                ) {
                    // TODO: 自动化功能
                }
            }
        }
        .sheet(isPresented: $showCreateTable) {
            CreateTableView()
        }
    }
} 