//
//  PostCardView.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 24.04.2025.
//

import SwiftUI

struct PostCardView: View {
    @State var post: PostModel.PostData
    @State private var bookmarkFilled: Bool = true
    
    var body: some View {
        VStack{
            topPostLine(for: post)
            
            HStack{
                Text(post.title)
                    .font(.title2)
                Spacer()
            }
            
            Spacer().frame(height: 5)
            
            if let mainPostText = post.mainText{
                Text(mainPostText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let image = post.image, let uiImage = UIImage(data: image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
            
            bottomPostLine(for: post)
            
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding(10)
        .background(Color(red: 220/255, green: 205/255, blue: 205/255))
        .foregroundStyle(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 2)
        .padding(20)
    }
    
    
    @ViewBuilder
    private func topPostLine (for post : PostModel.PostData) -> some View{
        HStack{
            Text(post.author)
                .font(.headline)
            Spacer()
            if let createdDate = post.createdUTCOwnPost {
                Text(DataManager().formatDate(createdDate))
            }
            Spacer()
            Text(post.domain)
            Spacer().frame(maxWidth: 100)
            Button(action: {
                PostsManager().deletePost(post: post)
                self.post.isSaved = false
                NotificationCenter.default.post(name: NSNotification.Name("PostUpdated"), object: nil, userInfo: ["post": self.post])
            }) {
                Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                    .imageScale(.large)
                    .foregroundStyle(.black)
            }
        }
    }
    
    @ViewBuilder
    private func bottomPostLine (for post : PostModel.PostData) -> some View{
        HStack{
            Button(action: {
                print("vote tapped")
            }) {
                Image(systemName: "arrow.up")
                Image(systemName: "xmark")
                Text(String(post.ups + post.downs))
            }
            Spacer()
            Button(action: {
                print("comments tapped")
            }) {
                HStack {
                    Image(systemName: "message")
                    Text(String(post.numComments))
                }
            }
            Spacer()
            Button(action: {
                print("share tapped")
            }) {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
                    .offset(y:4)
            }
        }
        .imageScale(.large)
        .foregroundStyle(.black)
    }
}


