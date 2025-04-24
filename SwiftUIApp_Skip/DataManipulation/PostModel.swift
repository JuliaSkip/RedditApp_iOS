//
//  PostModel.swift
//  SwiftUIApp_Skip
//
//  Created by Скіп Юлія Ярославівна on 23.04.2025.
//
import Foundation

struct PostModel{
    struct RedditResponse: Decodable {
        let data: RedditDataList
    }
    struct RedditDataList: Decodable {
        let children: [RedditChildren]
        let after: String?
    }
    struct RedditChildren: Decodable {
        let data: RedditData
    }
    struct RedditData: Decodable {
        let author_fullname: String
        let title: String
        let preview: Preview?
        let num_comments: Int
        let ups: Int
        let downs: Int
        let created_utc: Double
        let domain: String
        let permalink: String
    }
    struct Preview: Decodable {
        let images: [Image]
    }
    struct Image: Decodable {
        let source: ImageSource
    }
    struct ImageSource: Decodable {
        let url: String?
    }
    
    struct PostData:Codable, Equatable, Identifiable{
        let author: String
        let title: String
        let mainText: String?
        let image: Data?
        let createdUTCOwnPost: Date?
        let domain: String
        let numComments: Int
        let ups: Int
        let downs: Int
        let createdUTC: String?
        let imageUrl: String?
        var isSaved: Bool
        let after: String?
        let url: String?
        
        var id: String {
            return (title + (mainText ?? " ") + domain + (createdUTCOwnPost?.description ?? "")).hash.description
        }
        
        static func == (lhs: PostData, rhs: PostData) -> Bool {
            lhs.author == rhs.author
            && lhs.title == rhs.title
            && lhs.mainText == rhs.mainText
            && lhs.image == rhs.image
            && lhs.createdUTCOwnPost == rhs.createdUTCOwnPost
            && lhs.domain == rhs.domain
            && lhs.createdUTC == rhs.createdUTC
            && lhs.imageUrl == rhs.imageUrl
            && lhs.after == rhs.after
            && lhs.url == rhs.url
        }
    }
}
