import SwiftUI

struct DateFieldRow: View {
    @Binding var value: String
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var isFirstAppear = true
    
    var body: some View {
        HStack {
            Text(value.isEmpty ? "选择日期" : value)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showDatePicker = true
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .navigationTitle("选择日期")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            showDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy年MM月dd日"
                            value = formatter.string(from: selectedDate)
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            if isFirstAppear && value.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月dd日"
                value = formatter.string(from: Date())
                isFirstAppear = false
            }
        }
    }
}

#Preview {
    @Previewable @State var date = ""
    return DateFieldRow(value: $date)
        .padding()
}
