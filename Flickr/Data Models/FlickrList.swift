//
//  FlickrList.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

struct FlickrList: Codable {
    let page: Page
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case page = "photos"
        case stat
    }

    struct Page: Codable {
        let pageNumber, pages, perPage, total: Int
        let array: [Image]
        
        enum CodingKeys: String, CodingKey {
            case pages, total
            case pageNumber = "page"
            case perPage = "perpage"
            case array = "photo"
        }

        init(from decoder: Decoder) throws {
            let values      = try decoder.container(keyedBy: CodingKeys.self)
            self.pageNumber = try values.decodeIntMaybeString(forKey: .pageNumber)
            self.pages      = try values.decodeIntMaybeString(forKey: .pages)
            self.perPage    = try values.decodeIntMaybeString(forKey: .perPage)
            self.total      = try values.decodeIntMaybeString(forKey: .total)
            self.array      = try values.decode([Image].self, forKey: .array)
        }
        
        struct Image: Codable {
            let id, owner, secret, server: String
            let farm: Int
            let title: String
            let isPublic, isFriend, isFamily: Bool
            
            var url: URL {
                let str = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                return URL(string: str)!
            }
            
            enum CodingKeys: String, CodingKey {
                case id, owner, secret, server, farm, title
                case isPublic = "ispublic"
                case isFriend = "isfriend"
                case isFamily = "isfamily"
            }
            
            init(from decoder: Decoder) throws {
                let values      = try decoder.container(keyedBy: CodingKeys.self)
                self.id         = try values.decode(String.self, forKey: .id)
                self.owner      = try values.decode(String.self, forKey: .owner)
                self.secret     = try values.decode(String.self, forKey: .secret)
                self.server     = try values.decodeStringMaybeInt(forKey: .server)
                self.title      = try values.decodeStringMaybeInt(forKey: .title)
                self.farm       = try values.decodeIntMaybeString(forKey: .farm)
                self.isPublic   = try values.decodeBoolFromInt(forKey: .isPublic)
                self.isFriend   = try values.decodeBoolFromInt(forKey: .isFriend)
                self.isFamily   = try values.decodeBoolFromInt(forKey: .isFamily)
            }
        }
    } 
}
