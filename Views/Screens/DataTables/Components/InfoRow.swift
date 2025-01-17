import SwiftUI

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(label + "：")
                .foregroundColor(.secondary)
            
            Text(value)
                .foregroundColor(Color(hex: "1A202C"))
        }
        .font(.system(size: 14))
    }
}

#Preview {
    InfoRow(icon: "tag.fill", label: "标签", value: "示例值")
} 