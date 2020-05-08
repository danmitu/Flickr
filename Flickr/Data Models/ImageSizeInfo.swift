//
//  ImageSizeInfo.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

struct ImageSizeInfo: Decodable {
    let sizes: ImageSizes
}

struct ImageSizes: Decodable {
    let canBlog, canPrint, canDownload: Bool
    let array: [ImageSize]
    private let preferredSizeIndex: Int
    
    var preferredSize: ImageSize {
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
        let array = try values.decode([ImageSize].self, forKey: .array)
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
}

struct ImageSize: Decodable {
    let label: String
    let width: Float
    let height: Float
    let source: String
    let url: String
    let media: String

    enum CodingKeys: String, CodingKey {
        case label, width, height, source, url, media
    }
    
    init(from decoder: Decoder) throws {
        let values  = try decoder.container(keyedBy: CodingKeys.self)
        self.label  = try values.decode(String.self, forKey: .label)
        self.width  = try values.decodeFloatMaybeString(forKey: .width)
        self.height = try values.decodeFloatMaybeString(forKey: .height)
        self.source = try values.decode(String.self, forKey: .source)
        self.url    = try values.decode(String.self, forKey: .url)
        self.media  = try values.decode(String.self, forKey: .media)
    }
    
}

extension ImageSize {
    
    var size: CGSize {
        return CGSize(width: CGFloat(width),
                      height: CGFloat(height))
    }
    
}
