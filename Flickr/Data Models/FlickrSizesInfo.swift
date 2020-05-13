//
//  FlickrSizesInfo.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

struct FlickrSizesInfo: Decodable {
    let sizes: Sizes
    
    struct Sizes: Decodable {
        let canBlog, canPrint, canDownload: Bool
        let array: [SizeInfo]
        private let preferredSizeIndex: Int
        
        var preferredSize: SizeInfo {
            return array[preferredSizeIndex]
        }
        
        enum CodingKeys: String, CodingKey {
            case canBlog = "canblog"
            case canPrint = "canprint"
            case canDownload = "candownload"
            case array = "size"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.canBlog = try values.decodeBoolFromInt(forKey: .canBlog)
            self.canPrint = try values.decodeBoolFromInt(forKey: .canBlog)
            self.canDownload = try values.decodeBoolFromInt(forKey: .canBlog)
            let array = try values.decode([SizeInfo].self, forKey: .array)
            self.array = array
            let sizePreference = ["Small", "Medium", "Large", "Original"]
            let _preferredSizeIndex: Int = {
                for sizeLabel in sizePreference {
                    if let index = array.firstIndex(where: { $0.label == sizeLabel }) {
                        return index
                    }
                }
                return array.indices.last ?? 0
            }()
            self.preferredSizeIndex = _preferredSizeIndex
        }
        
        struct SizeInfo: Decodable {
            let label: String
            let size: Size
            let source: String
            let url: String
            let media: String

            enum CodingKeys: String, CodingKey {
                case label, width, height, source, url, media
            }
            
            init(from decoder: Decoder) throws {
                let values  = try decoder.container(keyedBy: CodingKeys.self)
                self.label  = try values.decode(String.self, forKey: .label)
                let width   = try values.decodeDoubleMaybeString(forKey: .width)
                let height  = try values.decodeDoubleMaybeString(forKey: .height)
                self.size   = Size(width: width, height: height)
                self.source = try values.decode(String.self, forKey: .source)
                self.url    = try values.decode(String.self, forKey: .url)
                self.media  = try values.decode(String.self, forKey: .media)
            }
            
        }

    }
}

struct Size: Codable {
    let width: Double
    let height: Double
}
