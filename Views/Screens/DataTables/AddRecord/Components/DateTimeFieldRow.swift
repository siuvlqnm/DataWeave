import SwiftUI

struct DateTimeFieldRow: View {
    @Binding var value: String
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isFirstAppear = true
    
    var body: some View {
        HStack(spacing: 4) {
            // 日期部分
            Text(getDatePart(from: value))
                .foregroundColor(value.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    showDatePicker = true
                }
            
            // 时间部分
            Text(getTimePart(from: value))
                .foregroundColor(value.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    showTimePicker = true
                }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
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
                            updateDateTime(updateDate: true)
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
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
                            updateDateTime(updateDate: false)
                            showTimePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
        }
        .onAppear {
            if isFirstAppear && value.isEmpty {
                let now = Date()
                selectedDate = now
                selectedTime = now
                updateDateTime(updateDate: true)
                isFirstAppear = false
            }
        }
    }
    
    private func getDatePart(from value: String) -> String {
        if value.isEmpty {
            return "选择日期"
        }
        let components = value.components(separatedBy: " ")
        let datePart = components.first ?? ""
        return datePart.isEmpty ? "选择日期" : datePart
    }
    
    private func getTimePart(from value: String) -> String {
        if value.isEmpty {
            return "选择时间"
        }
        let components = value.components(separatedBy: " ")
        let timePart = components.count > 1 ? components[1] : ""
        return timePart.isEmpty ? "选择时间" : timePart
    }
    
    private func updateDateTime(updateDate: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        if updateDate {
            let newDate = dateFormatter.string(from: selectedDate)
            let currentTime = getTimePart(from: value)
            if currentTime == "选择时间" {
                value = "\(newDate) \(timeFormatter.string(from: Date()))"
            } else {
                value = "\(newDate) \(currentTime)"
            }
        } else {
            let currentDate = getDatePart(from: value)
            let newTime = timeFormatter.string(from: selectedTime)
            if currentDate == "选择日期" {
                value = "\(dateFormatter.string(from: Date())) \(newTime)"
            } else {
                value = "\(currentDate) \(newTime)"
            }
        }
    }
}

#Preview {
    @Previewable @State var dateTime = ""
    return DateTimeFieldRow(value: $dateTime)
        .padding()
} 
