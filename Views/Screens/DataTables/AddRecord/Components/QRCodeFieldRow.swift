import SwiftUI
import AVFoundation

struct QRCodeFieldRow: View {
    @Binding var value: String
    @State private var showScanner = false
    
    var body: some View {
        HStack {
            Text(value.isEmpty ? "扫描二维码" : value)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
            Spacer()
            Image(systemName: "qrcode.viewfinder")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showScanner = true
        }
        .sheet(isPresented: $showScanner) {
            CodeScannerView(codeTypes: [.qr]) { result in
                switch result {
                case .success(let code):
                    value = code
                    showScanner = false
                case .failure(let error):
                    print("Scanning failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var qrCode = ""
    return QRCodeFieldRow(value: $qrCode)
        .padding()
} 
