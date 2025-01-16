import SwiftUI
import AVFoundation

struct BarcodeFieldRow: View {
    @Binding var value: String
    @State private var showScanner = false
    
    var body: some View {
        HStack {
            Text(value.isEmpty ? "扫描条形码" : value)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
            Spacer()
            Image(systemName: "barcode.viewfinder")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showScanner = true
        }
        .sheet(isPresented: $showScanner) {
            CodeScannerView(codeTypes: [.ean8, .ean13, .code128]) { result in
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

struct CodeScannerView: UIViewControllerRepresentable {
    let codeTypes: [AVMetadataObject.ObjectType]
    let completion: (Result<String, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // 实际项目中需要实现扫码功能
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#Preview {
    @Previewable @State var barcode = ""
    return BarcodeFieldRow(value: $barcode)
        .padding()
} 
