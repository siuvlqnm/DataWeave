import SwiftUI

struct KeyMetricsGrid: View {
    let table: DataTable
    let timeRange: TimeRange
    private let accentColor = Color(hex: "A020F0")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("关键指标")
                .font(.system(size: 18, weight: .bold))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "总记录数",
                    value: "\(table.records.count)",
                    trend: "+12%",
                    icon: "doc.text.fill"
                )
                
                MetricCard(
                    title: "本期新增",
                    value: calculateNewRecords(),
                    trend: "+5%",
                    icon: "plus.circle.fill"
                )
                
                MetricCard(
                    title: "完整度",
                    value: calculateCompleteness(),
                    trend: "+3%",
                    icon: "checkmark.circle.fill"
                )
                
                MetricCard(
                    title: "更新频率",
                    value: calculateUpdateFrequency(),
                    trend: "-2%",
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // 计算辅助方法
    private func calculateNewRecords() -> String {
        let interval = timeRange.dateInterval
        let newRecords = table.records.filter { record in
            interval.contains(record.createdAt)
        }.count
        return "\(newRecords)"
    }
    
    private func calculateCompleteness() -> String {
        // TODO: 计算数据完整度
        return "85%"
    }
    
    private func calculateUpdateFrequency() -> String {
        // TODO: 计算更新频率
        return "每日"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let trend: String
    let icon: String
    private let accentColor = Color(hex: "A020F0")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            Text(trend)
                .font(.system(size: 12))
                .foregroundColor(trend.hasPrefix("+") ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
} 