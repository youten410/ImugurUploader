//
//  ContentView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/07.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showingAlert:Bool = false
    @State private var pasteString:String  = ""
    @State private var showingToolbar:Bool = true
    @State var selectedItem: PhotosPickerItem?
    @State var image: UIImage?
    @State var isSelected: Bool = false
    @StateObject private var viewModel = ImgurDataViewModel()
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                ZStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(20)
                    }
                    
                    if(viewModel.isUploading) {
                        ProgressView()
                            .scaleEffect(2.0)
                    }
                    
                }
                
                
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label(
                        title: { Text("Pick a Photo") },
                        icon: { Image(systemName: "photo") }
                    )
                }
                .onChange(of: selectedItem) {
                    showingToolbar = false
                    Task {
                        guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
                        guard let uiImage = UIImage(data: imageData) else { return }
                        image = uiImage
                        isSelected = true
                    }
                }
                
                Button(action: {
                    Task {
                        await viewModel.postImage(image: image!)
                    }
                    
                }, label: {
                    Text("Start Upload")
                        .padding(5)
                        .background(isSelected ? .blue : .gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
                .disabled(!isSelected)
                
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ListView()) {
                        if showingToolbar {
                            Image(systemName: "photo.stack.fill")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoView()) {
                        if showingToolbar {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                UIPasteboard.general.string = pasteString
                
                return Alert(
                    title: Text("Image Uploaded!"),
                    message: Text("The URL has been copied to the clipboard."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $viewModel.isShowSheet,onDismiss: {
                image = nil
                showingToolbar = true
                
                /// データ永続化
                let newData = ImageData(url: viewModel.postedImageData!.data.link, deletehas: viewModel.postedImageData!.data.deletehash)
                modelContext.insert(newData)
            }){
                NavigationView {
                    Text("\(viewModel.postedImageData!.data.link)")
                        .textSelection(.enabled)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .toolbar {
                            ToolbarItem {
                                Button(action: {
                                    viewModel.isShowSheet = false
                                }, label: {
                                    Text("close")
                                })
                            }
                        }
                }
                
            }
        }
    }
}


#Preview {
    ContentView()
}

