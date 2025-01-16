import SwiftUI

struct TimeFieldRow: View {
    @Binding var value: String
    @State private var selectedTime = Date()
    @State private var showTimePicker = false
    @State private var isFirstAppear = true
    
    var body: some View {
        HStack {
            Text(value.isEmpty ? "选择时间" : value)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showTimePicker = true
        }
        .sheet(isPresented: $showTimePicker) {
            NavigationView {
                VStack {
                    Spacer()
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    Spacer()
                }
                .navigationTitle("选择时间")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showTimePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            value = formatter.string(from: selectedTime)
                            showTimePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
        .onAppear {
            if isFirstAppear && value.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                value = formatter.string(from: Date())
                isFirstAppear = false
            }
        }
    }
}

#Preview {
    @Previewable @State var time = ""
    return TimeFieldRow(value: $time)
        .padding()
} 
