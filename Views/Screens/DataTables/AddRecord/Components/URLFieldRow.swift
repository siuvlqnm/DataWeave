import SwiftUI

struct URLFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        TextField("请输入URL", text: $value)
            .textFieldStyle(.plain)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

#Preview {
    @Previewable @State var url = ""
    return URLFieldRow(value: $url)
        .padding()
} 
