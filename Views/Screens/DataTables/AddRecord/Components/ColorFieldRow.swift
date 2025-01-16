import SwiftUI

struct ColorFieldRow: View {
    @Binding var value: String
    @State private var selectedColor = Color.blue
    @State private var showColorPicker = false
    
    var body: some View {
        HStack {
            if !value.isEmpty {
                Circle()
                    .fill(Color(hex: value))
                    .frame(width: 24, height: 24)
            }
            
            Text(value.isEmpty ? "选择颜色" : value)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showColorPicker = true
        }
        .sheet(isPresented: $showColorPicker) {
            NavigationView {
                ColorPicker("选择颜色", selection: $selectedColor)
                    .padding()
                    .navigationTitle("选择颜色")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showColorPicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                value = selectedColor.toHex() ?? ""
                                showColorPicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
}

extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

#Preview {
    @Previewable @State var color = ""
    return ColorFieldRow(value: $color)
        .padding()
} 
