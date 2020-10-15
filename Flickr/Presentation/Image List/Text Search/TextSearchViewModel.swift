//
//  TextSearchViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/11/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class TextSearchViewModel: ImageListViewModel {

    @TrimmedString private(set) var query: String = ""
    
    override init() {
        super.init()
        self.endpointSource = { [weak self] in
            Flickr().search(text: self?.query ?? "", page: $0, perPage: 30)
        }
    }

    deinit {
        self.endpointSource = nil
    }
    
    func search(query: String) {
        self.query = query
        reset()
        appendNewPage()
    }
    
}
