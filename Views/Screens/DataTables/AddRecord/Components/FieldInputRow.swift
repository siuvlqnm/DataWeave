import SwiftUI

struct FieldInputRow: View {
    let type: DataField.FieldType
    @Binding var value: String
    
    var body: some View {
        switch type {
        case .text:
            TextFieldRow(value: $value)
        case .richText:
            RichTextFieldRow(value: $value)
        case .number:
            NumberFieldRow(value: $value)
        case .decimal:
            DecimalFieldRow(value: $value)
        case .boolean:
            BooleanFieldRow(value: $value)
        case .date:
            DateFieldRow(value: $value)
        case .time:
            TimeFieldRow(value: $value)
        case .dateTime:
            DateTimeFieldRow(value: $value)
        case .image:
            ImageFieldRow(value: $value)
        case .file:
            FileFieldRow(value: $value)
        case .email:
            EmailFieldRow(value: $value)
        case .phone:
            PhoneFieldRow(value: $value)
        case .url:
            URLFieldRow(value: $value)
        case .location:
            LocationFieldRow(value: $value)
        case .color:
            ColorFieldRow(value: $value)
        case .barcode:
            BarcodeFieldRow(value: $value)
        case .qrCode:
            QRCodeFieldRow(value: $value)
        }
    }
}
