import SwiftUI

struct InsightsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle(title: "数据洞察")
            
            InsightCard(
                title: "支出趋势分析",
                description: "本月餐饮支出较上月增长15%",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange
            )
            
            InsightCard(
                title: "数据质量提醒",
                description: "发现3个可能的重复记录",
                icon: "exclamationmark.triangle",
                color: .red
            )
        }
    }
} 