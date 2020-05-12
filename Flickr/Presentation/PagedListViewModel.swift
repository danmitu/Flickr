//
//  PagedListViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

class PagedListViewModel {
        
    private var photos = [ImageInfo]()
    private var sizes = [Identifier : ImageSizeInfo]()
    private var currentPage = 1
    private var numberPages: Int!
    private var totalImages: Int!
    private var isLoadingNextPage = false
    
    var nextPageLoaded: (([Identifier])->Void)?
    
    var errorOccurred: ((Error)->Void)?

    private var atLastPage: Bool {
        guard let numberPages = numberPages else { return false }
        return currentPage == numberPages
    }
    
    func identifier(at item: Int) -> Identifier { return photos[item].id }
    
    func url(at item: Int) -> URL { return photos[item].url }
    
    func size(at item: Int) -> CGSize {
        let id = photos[item].id
        let preferredSize = sizes[id]!.sizes.preferredSize
        return CGSize(width: CGFloat(preferredSize.width), height: CGFloat(preferredSize.height))
    }
    
    var numberOfItems: Int { return photos.count }

    func reset() {
        photos.removeAll()
        sizes.removeAll()
        currentPage = 1
        numberPages = nil
        totalImages = nil
        isLoadingNextPage = false
    }
        
    private func update(imageList: ImageList, sizeDict: [Identifier : ImageSizeInfo]) {
        photos.append(contentsOf: imageList.page.array)
        sizes.merge(dict: sizeDict)
        currentPage = imageList.page.page
        numberPages = imageList.page.pages
        totalImages = imageList.page.total
    }
    
    /// Erase any previous image list and load the new one. Completes with a list of the new photo identifiers.
    func load(_ endpoint: Endpoint<ImageList>) {
        reset()
        sharedLoad(endpoint: endpoint)
    }
    
    /// Load an image list, appending the results to existing results. Completes with a list of the newly added photo identifiers.
    func append(_ endpoint: Endpoint<ImageList>) {
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
    private func sharedLoad(endpoint: Endpoint<ImageList>) {
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
                var sizeDict = [Identifier:ImageSizeInfo]()
                imageList.page.array.forEach { photo in
                    zip.enter()
                    let sizeEndpoint = flickr.getSizes(photoId: photo.id)
                    Environment.env.session.download(sizeEndpoint) { sizeInfoResult in
                        defer { zip.leave() }
                        switch sizeInfoResult {
                        case let .failure(error):
                            error.log() // We just log the error because this doesn't break anything too serious.
                        case let .success(imageSize):
                            sizeDict[photo.id] = imageSize
                        }
                    }
                }
                zip.notify(queue: .main) {
                    this.update(imageList: imageList, sizeDict: sizeDict)
                    let identifiers = imageList.page.array.map { $0.id }
                    this.nextPageLoaded?(identifiers)
                }
            }
        }
    }
    
    
    
}
