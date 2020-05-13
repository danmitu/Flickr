//
//  Flickr.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

struct Flickr {
    
    private static let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
    
    private static let apiKey: String = {
        return propertyList("APIKeys", bundle: Bundle.main)["Flickr"] as! String
    }()

    func search(text: String, page: Int, perPage: Int) -> Endpoint<ImageList> {
        
        let query: [String:String] = [
            "method":"flickr.photos.search",
            "api_key":Flickr.apiKey,
            "text":text,
            "nojsoncallback":"1",
            "format":"json",
            "media":"photos",
            "page":"\(page)",
            "per_page":"\(perPage)"
        ]
        
        return Endpoint<ImageList>(
            json: .get,
            url: Flickr.baseURL,
            accept: ContentType.json,
            headers: [:],
            expectedStatusCode: expected200to300,
            query: query)
    }

    func getSizes(photoId: String) -> Endpoint<ImageSizeInfo> {
        
        let query = [
            "method":"flickr.photos.getSizes",
            "api_key":Flickr.apiKey,
            "photo_id":photoId,
            "nojsoncallback":"1",
            "format":"json",
        ]
        
        return Endpoint<ImageSizeInfo>(
            json: .get,
            url: Flickr.baseURL,
            accept: ContentType.json,
            headers: [:],
            expectedStatusCode: expected200to300,
            query: query
        )
    }
    
    func interesting(page: Int, perPage: Int) -> Endpoint<ImageList> {
        let query: [String:String] = [
            "method":"flickr.interestingness.getList",
            "api_key":Flickr.apiKey,
            "nojsoncallback":"1",
            "format":"json",
            "page":"\(page)",
            "per_page":"50"
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
