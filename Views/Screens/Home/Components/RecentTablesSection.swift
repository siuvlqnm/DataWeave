import SwiftUI

struct RecentTablesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "最近的数据表")
            
            ForEach(0..<3) { index in
                DataTableCard(
                    title: ["电影记录", "记账本", "读书笔记"][index],
                    description: ["本周新增 3 条记录", "支出分析已生成", "完成度 85%"][index],
                    icon: ["film", "creditcard", "book"][index],
                    color: [.purple, .blue, .green][index]
                )
            }
        }
    }
} 