import SwiftUI
import SwiftData

struct RecordRow: View {
    let record: DataRecord
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // 左侧主要内容
                if let firstField = record.table?.fields.sorted(by: { $0.sortIndex < $1.sortIndex }).first,
                   let value = record.values[firstField.id] {
                    VStack(alignment: .leading, spacing: 4) {
                        // 字段名称
                        Text(firstField.name)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        // 字段值
                        Text(value)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 右侧时间和箭头
                HStack(spacing: 8) {
                    Text(record.createdAt.formatted(.relative(presentation: .named)))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white)
            .contentShape(Rectangle())
            
            Divider()
                .padding(.leading, 16)
        }
    }
} 