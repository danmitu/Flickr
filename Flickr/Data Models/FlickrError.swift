//
//  FlickrError.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

struct FlickrError: Error, Codable {
    let stat: String
    let code: Int
    let message: String
}
