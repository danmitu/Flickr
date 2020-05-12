//
//  SearchViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/11/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

class SearchViewModel {

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
    
    func size(at item: Int) -> CGSize { pagedList.size(at: item) }
    
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
    
    func nextPage() {
        guard atLastPage == false, let query = query else { return }
        let endpoint = flickr.search(text: query, page: pagedList.currentPage + 1, perPage: perPage)
        pagedList.append(endpoint)
    }
        
}
