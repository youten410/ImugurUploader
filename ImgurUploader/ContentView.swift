//
//  ContentView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var uploadedImageUrl: URL?
    @State private var showingAlert = false
    
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button(action: {
                    uploadImageToImgur(image: image)
                }, label: {
                    Text("Upload to Imgur")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .padding(.horizontal)
            } else {
                Text("No image selected")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .padding()
            }
            
            Button(action: {
                showingImagePicker = true
            }, label: {
                Text("Select Image")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert(isPresented: $showingAlert) {
            UIPasteboard.general.string = "テスト"
            
            return Alert(
                title: Text("Image Uploaded!"),
                message: Text("The URL has been copied to the clipboard."),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("Imgur Uploader")
    }
    
    func uploadImageToImgur(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Failed to convert image to data")
            return
        }
        
        let url = URL(string: "https://api.imgur.com/3/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID 665c7bc84e08d25", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let dictionary = json as? [String: Any],
                   let link = dictionary["data"] as? [String: Any],
                   let urlString = link["link"] as? String,
                   let url = URL(string: urlString) {
                    print("Uploaded to Imgur: \(url.absoluteString)")
                    
                    DispatchQueue.main.async {
                        uploadedImageUrl = url
                        showingAlert = true
                        selectedImage = nil
                        uploadedImageUrl = nil
                        showingImagePicker = false
                    }
                }
            } else {
                print("Error: Unexpected response")
            }
        }
        
        task.resume()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
