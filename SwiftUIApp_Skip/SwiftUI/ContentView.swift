//
//  ContentView.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 21.04.2025.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject var postsManager = PostsManager()
    
    @State private var authorName: String = UserDefaults.standard.string(forKey: "username") ?? ""
    
    @State private var postImgItem: PhotosPickerItem?
    @State private var postImgData: Data?
    @State private var postTitle: String = ""
    @State private var postContent: String = ""
    
    @State private var navPath = NavigationPath()
    @State private var isAuthorEmpty: Bool = false
    @State private var isDataMissing : Bool = false
    @State private var isTitleTooBig : Bool = false
    @State private var isImportingFromFiles = false


    
    var body: some View {
        VStack{
            NavigationStack(path: $navPath){
                Spacer()
                
                SwiftUIPostListViewController()
                
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(
                        value: "add",
                        label: {
                            Image(systemName: "plus.square.fill")
                                .imageScale(.large)
                                .foregroundStyle(.black)
                        }
                    )
                    Spacer()
                    NavigationLink(
                        value: "settings",
                        label: {
                            Image(systemName: "person.crop.circle")
                                .imageScale(.large)
                                .foregroundStyle(.black)
                        }
                    )
                    Spacer()
                }
                .navigationDestination(for: String.self, destination: { n in
                    if n == "add" {
                        self.createPost()
                           
                    } else {
                        self.settings(for: authorName)
                    }
                }
                )
            }
        }
    }
    
    
    @ViewBuilder
    private func postsList (with posts: [PostModel.PostData]) -> some View{
        if posts.isEmpty{
            Image("reddit_guy")
                .resizable()
                .frame(width: 150, height: 250)
            Text("There are no posts yet...")
                .font(.title)
                .foregroundStyle(.black)
        }
        else{
            ScrollView{
                LazyVStack{
                    ForEach(posts){ post in
                        PostCardView(post: post)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    private func createPost () -> some View{
        ScrollView{
            Spacer().frame(height: 50)
            
            Text("Create your post!")
                .font(.largeTitle)
                .padding(20)
            
            inputFields()
            
            if isDataMissing{
                Text("Fill all the fields before posting!")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            if isTitleTooBig{
                Text("Title must be less than 50 characters long!")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            
            postButton()
            
            Spacer()
        }
        
    }
    
    @ViewBuilder
    private func inputFields () -> some View{
        VStack(alignment: .leading){
            
            Text("Title")
            TextField("Enter your title here!", text: $postTitle)
                .padding(10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
            
            Text("Content")
            TextEditor(text: $postContent)
                .padding(10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray, lineWidth: 1)
                )
                .frame(height: 150)

            Text("Image")
            imagePicker()
            
        }.padding(20)
    }

    
    @ViewBuilder
    private func imagePicker () -> some View{
        VStack {
            if let postImgData,
               let uiImage = UIImage(data: postImgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            
            HStack{
                Spacer()
                Image(systemName: "photo")
                PhotosPicker("Select an image from library", selection: $postImgItem, matching: .images)
                Spacer()
            }
            .foregroundStyle(.black)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            Text("Or")
            
            VStack {
                Button {
                    isImportingFromFiles.toggle()
                } label: {
                    HStack{
                        Spacer()
                        Image(systemName: "document")
                        Text("Select an image from documents")
                        Spacer()
                    }
                    .foregroundStyle(.black)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                .fileImporter(isPresented: $isImportingFromFiles, allowedContentTypes: [UTType.image], allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        do {
                            let data = try Data(contentsOf: url)
                            postImgData = data
                        } catch {
                            print("Error loading image: \(error)")
                        }

                    case .failure(let error):
                        print("File import failed: \(error)")
                    }
                }
            }
        }
        .onChange(of: postImgItem) {
            Task {
                    if let data = try? await postImgItem?.loadTransferable(type: Data.self) {
                        postImgData = data
                    } else {
                        print("Failed to load image data")
                    }
                }
        }
        
    }
    
    
    @ViewBuilder
    private func postButton () -> some View{
        Button(action: {
            if postTitle.isEmpty || postContent.isEmpty{
                isDataMissing = true
            }else if postTitle.count > 50 {
                isTitleTooBig = true
            }
            else if (UserDefaults.standard.object(forKey: "username") == nil) {
                isAuthorEmpty = true
            }else{
                postsManager.createNewPost(author: authorName, title: postTitle, content: postContent, image: postImgData)
                postTitle = ""
                postContent = ""
                postImgData = nil
                
                DispatchQueue.main.async {
                    navPath = NavigationPath()
                }
            }
               
        }){
            Text("Post!")
                .frame(width: 70, height: 30)
                .background(Color.black)
                .foregroundStyle(.white)
                .cornerRadius(30)
                .font(.headline)
            
        }.alert("Missing Information", isPresented: $isAuthorEmpty) {
            Button("Go to settings") {
                    navPath.append("settings")
            }
        } message: {
            Text("Please tell us your name before posting.")
        }
    }
    
    
    @ViewBuilder
    private func settings (for authorName: String?) -> some View{
        Text("Settings")
            .font(.largeTitle)
            .padding(20)
        
        VStack(alignment: .leading){
            Text("Author name")
            TextField("Enter your name here!", text: $authorName)
                .padding(10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }.padding(20)
        
        Button(action: {
            UserDefaults.standard.set(authorName, forKey: "username")
            DispatchQueue.main.async {
                navPath = NavigationPath()
            }
        }) {
            Text("Save")
                .frame(width: 70, height: 30)
                .background(Color.black)
                .foregroundStyle(.white)
                .cornerRadius(30)
                .font(.headline)
        }
        
        Spacer()
        
    }
}



#Preview {
    ContentView()
}
