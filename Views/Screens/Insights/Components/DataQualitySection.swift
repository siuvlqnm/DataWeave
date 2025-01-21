import SwiftUI

struct DataQualitySection: View {
    let table: DataTable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("数据质量")
                .font(.headline)
            
            VStack(spacing: 12) {
                QualityIndicator(
                    title: "完整性",
                    value: calculateCompleteness(),
                    description: "字段填写完整度"
                )
                
                QualityIndicator(
                    title: "一致性",
                    value: calculateConsistency(),
                    description: "数据格式一致性"
                )
                
                QualityIndicator(
                    title: "时效性",
                    value: calculateTimeliness(),
                    description: "数据更新及时性"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    // 计算辅助方法
    private func calculateCompleteness() -> Double {
        // TODO: 计算完整性得分
        return 0.85
    }
    
    private func calculateConsistency() -> Double {
        // TODO: 计算一致性得分
        return 0.92
    }
    
    private func calculateTimeliness() -> Double {
        // TODO: 计算时效性得分
        return 0.78
    }
}

struct QualityIndicator: View {
    let title: String
    let value: Double
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            
            ProgressView(value: value)
                .tint(.accentColor)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 