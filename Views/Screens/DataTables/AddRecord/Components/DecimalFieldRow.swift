import SwiftUI

struct DecimalFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入小数", text: $value)
            .textFieldStyle(.plain)
            .keyboardType(.decimalPad)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onChange(of: value) { newValue in
                // 只允许输入数字和小数点
                let filtered = newValue.filter { $0.isNumber || $0 == "." }
                // 确保只有一个小数点
                if filtered.filter({ $0 == "." }).count > 1 {
                    let components = filtered.split(separator: ".", omittingEmptySubsequences: false)
                    if components.count >= 2 {
                        value = components[0] + "." + components[1]
                    }
                } else if filtered != newValue {
                    value = filtered
                }
            }
    }
}

#Preview {
    @Previewable @State var decimal = ""
    return DecimalFieldRow(value: $decimal)
        .padding()
} 
