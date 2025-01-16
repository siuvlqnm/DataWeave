import SwiftUI
import UIKit

struct ImageFieldRow: View {
    @Binding var value: String
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else if !value.isEmpty, let imageData = Data(base64Encoded: value),
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("点击选择图片")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .onTapGesture {
                    showImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage) { image in
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    value = imageData.base64EncodedString()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var image = ""
    return ImageFieldRow(value: $image)
        .padding()
} 
