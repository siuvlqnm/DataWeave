import SwiftUI

struct TextFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入文本", text: $value)
            .textFieldStyle(.plain)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    @Previewable @State var text = ""
    return TextFieldRow(value: $text)
        .padding()
}
