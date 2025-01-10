import SwiftUI

struct DataMetricCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let trendValue: String
    
    enum TrendDirection {
        case up, down, neutral
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            HStack {
                Image(systemName: trend == .up ? "arrow.up.right" : 
                                trend == .down ? "arrow.down.right" : "minus")
                Text(trendValue)
                    .font(.system(size: 12))
            }
            .foregroundColor(trend == .up ? .green : 
                           trend == .down ? .red : .gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
} 