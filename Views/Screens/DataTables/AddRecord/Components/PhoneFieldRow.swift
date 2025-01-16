import SwiftUI

struct PhoneFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入电话号码", text: $value)
            .textFieldStyle(.plain)
            .keyboardType(.phonePad)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onChange(of: value) { newValue in
                // 只允许输入数字和加号
                let filtered = newValue.filter { $0.isNumber || $0 == "+" }
                if filtered != newValue {
                    value = filtered
                }
            }
    }
}

#Preview {
    @Previewable @State var phone = ""
    return PhoneFieldRow(value: $phone)
        .padding()
} 
