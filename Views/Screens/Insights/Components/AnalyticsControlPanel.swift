import SwiftUI

struct AnalyticsControlPanel: View {
    @Binding var timeRange: TimeRange
    @Binding var selectedMetrics: Set<InsightMetric>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分析设置")
                .font(.headline)
            
            // 时间范围选择器
            VStack(alignment: .leading, spacing: 8) {
                Text("时间范围")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("时间范围", selection: $timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 指标选择器
            VStack(alignment: .leading, spacing: 8) {
                Text("分析指标")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(InsightMetric.allCases, id: \.self) { metric in
                            Toggle(metric.rawValue, isOn: Binding(
                                get: { selectedMetrics.contains(metric) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedMetrics.insert(metric)
                                    } else {
                                        selectedMetrics.remove(metric)
                                    }
                                }
                            ))
                            .toggleStyle(.button)
                        }
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