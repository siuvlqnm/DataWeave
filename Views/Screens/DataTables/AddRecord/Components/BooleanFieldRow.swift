import SwiftUI

struct BooleanFieldRow: View {
    @Binding var value: String
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { value == "true" },
            set: { value = $0 ? "true" : "false" }
        )) {
            EmptyView()
        }
        .padding()
        .tint(.purple)
    }
}

#Preview {
    @Previewable @State var boolean = "false"
    return BooleanFieldRow(value: $boolean)
        .padding()
}
