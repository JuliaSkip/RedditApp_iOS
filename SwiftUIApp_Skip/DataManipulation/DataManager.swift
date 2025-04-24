//
//  DataFetcher.swift
//  Skip02
//
//  Created by Скіп Юлія Ярославівна on 15.03.2025.
//

import Kingfisher
import Foundation

class DataManager {
    
    private let fileName = "posts.json"
    
    private struct Parameters {
        private var parameters: [String: String] = [:]
        
        mutating func add(key: String, value: String) {
            parameters[key] = value
        }
        
        func getParams() -> String {
            guard !parameters.isEmpty else { return "" }
            return parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        }
    }
    
    private func fetchUrl(from: String, params: Parameters) async throws -> (posts: [PostModel.RedditData?], after: String?){
        let fullUrl = from + "?" + params.getParams()
        guard let url = URL(string: fullUrl) else { return ([], nil)}
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(PostModel.RedditResponse.self, from: data)
        let posts = decodedResponse.data.children.map { $0.data }
        return (posts, decodedResponse.data.after)
    }

    func getPost(subreddit: String, limit: Int, after: String?) async throws -> (posts: [PostModel.RedditData?], after: String?) {
        var parameters = Parameters()
        parameters.add(key: "limit", value: "\(limit)")
        if let after = after {
            parameters.add(key: "after", value: after)
        }
        let urlString = "https://www.reddit.com/r/\(subreddit)/top.json"
        
        return try await fetchUrl(from: urlString, params: parameters)
    }
    
    func fetchPosts(subreddit:String, limit: Int, after: String?) async -> [PostModel.PostData]? {
        
        do {
            let (result, afterToken) = try await getPost(subreddit: subreddit, limit: limit, after: after)
            
            let posts = result
            
            let filteredPosts = posts.compactMap { post -> PostModel.PostData? in
                guard let post = post else { return nil }
                let formattedDate = formatDate(Date(timeIntervalSince1970:post.created_utc))
                
                let imageUrl = post.preview?.images.first?.source.url
                return PostModel.PostData (
                    author: post.author_fullname,
                    title: post.title,
                    mainText: nil,
                    image: nil,
                    createdUTCOwnPost: nil,
                    domain: post.domain,
                    numComments: post.num_comments,
                    ups: post.ups,
                    downs: post.downs,
                    createdUTC: formattedDate,
                    imageUrl: imageUrl,
                    isSaved: false,
                    after: afterToken,
                    url: "https://www.reddit.com" + post.permalink
                )
            }
            
            return filteredPosts
            
        } catch {
            print("Failed to fetch data: \(error)")
        }
        
        return nil
    }

    
    func formatDate(_ date: Date) -> String {
        
        let timePassed = Date().timeIntervalSince(date)
        
        let days = Int(timePassed) / 86400
        let hours = (Int(timePassed) % 86400) / 3600
        let minutes = (Int(timePassed) % 3600) / 60
        
        if(days > 0){
            return "\(days) d"
        }else if(hours > 0){
            return "\(hours) h"
        }else if (minutes > 0){
            return "\(minutes) m"
        }else{
            return "now"
        }
    }
}
