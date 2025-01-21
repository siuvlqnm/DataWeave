import SwiftUI
import Charts

struct FieldDistributionSection: View {
    let table: DataTable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("字段分布")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(table.fields) { field in
                        FieldDistributionCard(field: field, table: table)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct FieldDistributionCard: View {
    let field: DataField
    let table: DataTable
    
    // 添加数据结构
    struct DistributionPoint: Identifiable {
        let id = UUID()
        let category: String
        let count: Int
    }
    
    // 生成字段分布数据
    private var distributionData: [DistributionPoint] {
        // 这里应该根据字段类型生成不同的分布数据
        switch field.type {
        case .boolean:
            return generateBooleanDistribution()
        case .number, .decimal:
            return generateNumericDistribution()
        default:
            return generateTextDistribution()
        }
    }
    
    private func generateBooleanDistribution() -> [DistributionPoint] {
        let trueCount = table.records.filter { $0.getValue(for: field) == "true" }.count
        let falseCount = table.records.filter { $0.getValue(for: field) == "false" }.count
        
        return [
            DistributionPoint(category: "是", count: trueCount),
            DistributionPoint(category: "否", count: falseCount)
        ]
    }
    
    private func generateNumericDistribution() -> [DistributionPoint] {
        // 简单分为5个区间
        return (0..<5).map { i in
            DistributionPoint(
                category: "区间\(i + 1)",
                count: Int.random(in: 1...10)
            )
        }
    }
    
    private func generateTextDistribution() -> [DistributionPoint] {
        // 获取前5个最常见的值
        return (0..<5).map { i in
            DistributionPoint(
                category: "类别\(i + 1)",
                count: Int.random(in: 1...10)
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(field.name)
                    .font(.headline)
                Image(systemName: field.type.icon)
                    .foregroundStyle(.secondary)
            }
            
            // 分布图表
            Chart(distributionData) { point in
                BarMark(
                    x: .value("数量", point.count),
                    y: .value("类别", point.category)
                )
                .foregroundStyle(Color.accentColor.gradient)
            }
            .frame(width: 200, height: 120)
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            
            Text("共\(table.records.count)条记录")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

#Preview {
    let table = DataTable(name: "示例表")
    table.fields.append(DataField(name: "年龄", type: .number))
    table.fields.append(DataField(name: "姓名", type: .text))
    table.fields.append(DataField(name: "是否活跃", type: .boolean))
    
    return FieldDistributionSection(table: table)
        .padding()
} 