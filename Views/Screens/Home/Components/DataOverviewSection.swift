import SwiftUI

struct DataOverviewSection: View {
    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DataMetricCard(title: "活跃数据表", value: "12", trend: .up, trendValue: "+3")
                DataMetricCard(title: "本周新增记录", value: "156", trend: .up, trendValue: "+22%")
                DataMetricCard(title: "数据完整度", value: "94%", trend: .up, trendValue: "+5%")
                DataMetricCard(title: "自动化任务", value: "8", trend: .neutral, trendValue: "运行中")
            }
        }
        .padding(.top)
    }
} 