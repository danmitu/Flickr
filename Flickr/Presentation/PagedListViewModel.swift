//
//  PagedListViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class PagedListViewModel {
        
    private var photos = [FlickrList.Page.Image]()
    private var sizes = [Identifier : FlickrSizesInfo]()
    private(set) var currentPage = 1
    private var numberPages: Int!
    private var totalImages: Int!
    private var isLoadingNextPage = false
    private(set) var identfiers = Set<Identifier>()
    
    var nextPageLoaded: (([Identifier])->Void)?
    
    var errorOccurred: ((Error)->Void)?
    
    var atLastPage: Bool {
        guard let numberPages = numberPages else { return false }
        return currentPage == numberPages
    }
    
    func identifier(at item: Int) -> Identifier { return photos[item].id }
    
    func url(at item: Int) -> URL { return photos[item].url }
    
    func size(at item: Int) -> Size {
        let id = photos[item].id
        let preferredSize = sizes[id]!.sizes.preferredSize
        return preferredSize.size
    }
    
    var numberOfItems: Int { return photos.count }

    func reset() {
        photos.removeAll()
        sizes.removeAll()
        currentPage = 1
        numberPages = nil
        totalImages = nil
        isLoadingNextPage = false
        identfiers.removeAll()
    }
        
    private func update(imageList: FlickrList, sizeDict: [Identifier : FlickrSizesInfo]) {
        photos.append(contentsOf: imageList.page.array)
        sizes.merge(dict: sizeDict)
        currentPage = imageList.page.pageNumber
        numberPages = imageList.page.pages
        totalImages = imageList.page.total
    }
    
    /// Erase any previous image list and load the new one. Completes with a list of the new photo identifiers.
    func load(_ endpoint: Endpoint<FlickrList>) {
        reset()
        sharedLoad(endpoint: endpoint)
    }
    
    /// Load an image list, appending the results to existing results. Completes with a list of the newly added photo identifiers.
    func append(_ endpoint: Endpoint<FlickrList>) {
        sharedLoad(endpoint: endpoint)
    }

    /**
     1. Gets the image list.
     2. For each image, gets ("zip") the size.
     3. Updates internal data.
     - Parameters:
     - endpoint: Endpoint to retrieve.
     - onComplete: Receives a result containing the identifeirs for the newly loaded photos.
     */
    private func sharedLoad(endpoint: Endpoint<FlickrList>) {
        guard !atLastPage else { return }
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        Environment.env.session.download(endpoint) { [weak self] imageListResult in
            guard let this = self else { return }
            this.isLoadingNextPage = false
            switch imageListResult {
            case let .failure(error):
                this.errorOccurred?(error)
            case let .success(imageList):
                let flickr = Flickr()
                let zip = DispatchGroup() /// Retrieve `ImageSizeInfo` for each photo in the image list.
                var sizeDict = [Identifier:FlickrSizesInfo]()
                let pageIdentifiers = Set(imageList.page.array.map { $0.id })
                let newUniqueIdentifiers = pageIdentifiers.subtracting(this.identfiers)
                newUniqueIdentifiers.forEach { id in
                    zip.enter()
                    let sizeEndpoint = flickr.getSizes(photoId: id)
                    this.identfiers.insert(id)
                    Environment.env.session.download(sizeEndpoint) { sizeInfoResult in
                        defer { zip.leave() }
                        switch sizeInfoResult {
                        case let .failure(error):
                            error.log() // We just log the error because this doesn't break anything too serious.
                        case let .success(imageSize):
                            sizeDict[id] = imageSize
                        }
                    }
                }
                zip.notify(queue: .main) {
                    this.update(imageList: imageList, sizeDict: sizeDict)
                    this.nextPageLoaded?(Array(newUniqueIdentifiers))
                }
            }
        }
    }
    
    
    
}
