import SwiftUI
import UniformTypeIdentifiers

struct FileFieldRow: View {
    @Binding var value: String
    @State private var showFilePicker = false
    @State private var fileName: String = ""
    
    var body: some View {
        HStack {
            if !fileName.isEmpty {
                Image(systemName: "doc.fill")
                    .foregroundColor(.blue)
                Text(fileName)
                    .lineLimit(1)
            } else {
                Text("选择文件")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showFilePicker = true
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let files):
                if let file = files.first {
                    fileName = file.lastPathComponent
                    // 这里可以处理文件，比如复制到应用目录或上传到服务器
                    value = file.lastPathComponent
                }
            case .failure(let error):
                print("Error selecting file: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    @Previewable @State var file = ""
    return FileFieldRow(value: $file)
        .padding()
} 
