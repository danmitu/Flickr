//
//  TextSearchViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/11/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class TextSearchViewModel: ImageListViewModel {

    private(set) var query: String?
    
    override init() {
        super.init()
        self.endpointSource = { [weak self] in
            Flickr().search(text: self!.query!, page: $0, perPage: 30)
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

/*
class TextQueryViewModel {

    /**
     This class is mostly just a wrapper around `PagedListViewModel`.
     */
    
    private let pagedList = PagedListViewModel()
    private let flickr = Flickr()
    private let perPage = 30
    
    var nextPageLoaded: (([Identifier])->Void)? {
        get { return pagedList.nextPageLoaded }
        set { pagedList.nextPageLoaded = newValue }
    }
    
    var errorOccurred: ((Error)->Void)? {
        get { return pagedList.errorOccurred }
        set { pagedList.errorOccurred = newValue }
    }
    
    var atLastPage: Bool { return pagedList.atLastPage }
    
    private var query: String?
    
    func identifier(at item: Int) -> Identifier { return pagedList.identifier(at: item) }
    
    func url(at item: Int) -> URL { return pagedList.url(at: item) }
    
    func size(at item: Int) -> Size { pagedList.size(at: item) }
    
    var numberOfItems: Int { return pagedList.numberOfItems }

    func reset() {
        query = nil
        pagedList.reset()
    }
    
    func search(query: String) {
        reset()
        self.query = query
        let endpoint = flickr.search(text: query, page: 1, perPage: perPage)
        pagedList.load(endpoint)
    }
    
    func loadNextPage() {
        guard atLastPage == false, let query = query else { return }
        let endpoint = flickr.search(text: query, page: pagedList.currentPage + 1, perPage: perPage)
        pagedList.append(endpoint)
    }
        
}
*/
