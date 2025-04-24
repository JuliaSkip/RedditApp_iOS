//
//  PostDataModel.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 21.04.2025.
//

import Foundation
import SwiftUI

class PostsManager: ObservableObject{
    
    typealias PostDataModel = PostModel.PostData
    private let fileName = "posts.json"
    
    
    func getPosts() -> [PostDataModel]{
        return loadPostsFromFile()
    }
    
    func createNewPost(author: String, title: String, content: String, image: Data?){
        let newPost = PostDataModel(author: author, title: title, mainText: content, image: image, createdUTCOwnPost: Date.now, domain: "r/ios", numComments: 0, ups: 0, downs: 0, createdUTC: nil, imageUrl: nil, isSaved: true, after: nil, url: nil)
        
        var loadedPosts = loadPostsFromFile()
        
        loadedPosts.append(newPost)
        
        writePostsToFile(posts: loadedPosts)
    }
    
    func deletePost(post: PostDataModel) {
        var loadedPosts = loadPostsFromFile()
        
        if let index = loadedPosts.firstIndex(where: { $0 == post}) {
            loadedPosts.remove(at: index)
        }
        
        writePostsToFile(posts: loadedPosts)
    }
    
    
    func writePostsToFile(posts: [PostDataModel]){
        do {
            let data = try JSONEncoder().encode(posts)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        }catch {
            print("Error saving JSON: \(error)")
        }
    }
    
    func loadPostsFromFile() -> [PostDataModel] {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
        let data = try? Data(contentsOf: filePath) else { return [] }
            
        do {
            let results = try JSONDecoder().decode([PostDataModel].self, from: data)
            return results
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
    
}

