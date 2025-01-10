import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    QuickActionButton(
        icon: "plus.circle.fill",
        title: "新建数据表",
        color: .purple,
        action: {}
    )
    .padding()
} 
