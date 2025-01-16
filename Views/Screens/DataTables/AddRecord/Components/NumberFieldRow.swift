import SwiftUI

struct NumberFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入数字", text: $value)
            .textFieldStyle(.plain)
            .keyboardType(.numberPad)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onChange(of: value) { newValue in
                // 只允许输入数字
                let filtered = newValue.filter { $0.isNumber }
                if filtered != newValue {
                    value = filtered
                }
            }
    }
}

#Preview {
    @Previewable @State var number = ""
    return NumberFieldRow(value: $number)
        .padding()
}
