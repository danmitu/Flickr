//
//  Flickr.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

public struct Flickr {
    
    private static let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
    
    private static let apiKey: String = {
        return propertyList("APIKeys", bundle: Bundle.main)["Flickr"] as! String
    }()

    func search(text: String, page: Int) -> Endpoint<ImageList> {
        
        let query: [String:String] = [
            "method":"flickr.photos.search",
            "api_key":Flickr.apiKey,
            "text":text,
            "nojsoncallback":"1",
            "format":"json",
            "media":"photos",
            "page":"\(page)",
            "per_page":"30"
        ]
        
        return Endpoint<ImageList>(
            json: .get,
            url: Flickr.baseURL,
            accept: ContentType.json,
            headers: [:],
            expectedStatusCode: expected200to300,
            query: query)
    }

}
