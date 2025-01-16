import SwiftUI

struct RichTextFieldRow: View {
    @Binding var value: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $value)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .focused($isFocused)
                .overlay(
                    Group {
                        if value.isEmpty && !isFocused {
                            Text("请输入内容")
                                .foregroundColor(.gray)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    return RichTextFieldRow(value: $text)
        .padding()
}
