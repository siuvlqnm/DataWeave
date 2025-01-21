import SwiftUI
import Charts

struct TrendAnalysisSection: View {
    let table: DataTable
    let timeRange: TimeRange
    let metrics: Set<InsightMetric>
    
    // 添加示例数据结构
    struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Int
        let category: String
    }
    
    // 生成示例数据
    private var sampleData: [DataPoint] {
        let calendar = Calendar.current
        let startDate = timeRange.dateInterval.start
        let endDate = timeRange.dateInterval.end
        
        var points: [DataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            points.append(DataPoint(
                date: currentDate,
                value: Int.random(in: 10...100),
                category: "记录数"
            ))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("趋势分析")
                .font(.headline)
            
            // 趋势图表
            Chart(sampleData) { point in
                LineMark(
                    x: .value("日期", point.date),
                    y: .value("数量", point.value)
                )
                .foregroundStyle(by: .value("类别", point.category))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

#Preview {
    TrendAnalysisSection(
        table: DataTable(name: "示例表"),
        timeRange: .week,
        metrics: [.recordCount]
    )
    .padding()
} 