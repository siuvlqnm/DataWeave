import SwiftUI

struct EmailFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入邮箱地址", text: $value)
            .textFieldStyle(.plain)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    @Previewable @State var email = ""
    return EmailFieldRow(value: $email)
        .padding()
} 
