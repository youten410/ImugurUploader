//
//  ListView.swift
//  ImgurUploader
//
//  Created by Shun Sato on 2024/01/08.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.dismiss) var dismiss
    @Query private var images: [ImageData]
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Uploaded Images")) {
                    ForEach(images, id: \.self) { image in
                        let imageUrl = image.url
                        
                        HStack {
                            if let imageUrl = URL(string: imageUrl) {
                                    AsyncImage(url: imageUrl) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                        case .empty:
                                            ProgressView()
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(image.url)
                                    .textSelection(.enabled)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                HStack {
                                    Text("(Delete Code)")
                                    
                                    Text(image.deletehas)
                                        .textSelection(.enabled)
                                }
                                .font(.caption2)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
    
}



#Preview {
    ListView()
}

