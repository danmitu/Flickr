//
//  InterestingViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/12/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class InterestingViewModel {

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
        
    func identifier(at item: Int) -> Identifier { return pagedList.identifier(at: item) }
    
    func url(at item: Int) -> URL { return pagedList.url(at: item) }
    
    func size(at item: Int) -> Size { pagedList.size(at: item) }
    
    var numberOfItems: Int { return pagedList.numberOfItems }

    func reset() {
        pagedList.reset()
    }
    
    func load() {
        reset()
        let endpoint = flickr.interesting(page: 0, perPage: perPage)
        pagedList.load(endpoint)

    }
        
    func loadNextPage() {
        guard atLastPage == false else { return }
        let endpoint = flickr.interesting(page: pagedList.currentPage + 1, perPage: perPage)
        pagedList.append(endpoint)
    }
        
}
