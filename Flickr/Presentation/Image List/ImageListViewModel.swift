//
//  ImageListViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class ImageListViewModel {

    deinit {
        runningTasks.values.forEach { $0.cancel() }
    }

    /// Provides the endpoint to update the collection given a page number.
    var endpointSource: ((Int)->Endpoint<FlickrList>)?
    
    /// Passes any newly loaded identifiers.
    var nextPageLoaded: (([Identifier])->Void)?
    
    /// Passes any errors that occurred.
    var errorOccurred: ((Error)->Void)?

    struct Item {
        let identifier: String
        let url: URL
        let size: Size?
    }
    
    private var identifiers = [Identifier]()
    private var items = [Identifier:Item]()
    
    func item(at index: Int) -> Item {
        let key = identifiers[index]
        return items[key]!
    }
    
    var numberOfItems: Int { identifiers.count }
    
    @PositiveInt private(set) var currentPage = 1
    @OptionalPostiveInt private var numberPages = nil
    @OptionalPostiveInt private var totalImages = nil
    private var isLoadingNextPage = false
    
    private var runningTasks = [UUID:URLSessionTask]()
    
    func reset() {
        currentPage = 1
        numberPages = nil
        totalImages = nil
        identifiers.removeAll()
        items.removeAll()
        runningTasks.values.forEach { $0.cancel() }
        runningTasks.removeAll()
    }
    
    private func update(imageList: FlickrList, newItems: [Identifier:Item]) {
        identifiers.append(contentsOf: imageList.page.array.map { $0.id })
        items.merge(dict: newItems)
        currentPage = imageList.page.pageNumber
        numberPages = imageList.page.pages
        totalImages = imageList.page.total
    }

    var isLastPage: Bool { return currentPage == numberPages }
    
    func appendNewPage() {
        guard !isLastPage else { return }
        guard !isLoadingNextPage else { return }
        guard let endpointSource = endpointSource else { return }
        isLoadingNextPage = true
        let flickr = Flickr()
        let session = Environment.env.session
        let endpoint = endpointSource(currentPage + 1)
        let listTaskId = UUID()
        let listTask = session.download(endpoint) { [weak self] result in
            guard let this = self else { return }
            this.runningTasks[listTaskId] = nil
            switch result {
            case let .failure(error):
                this.errorOccurred?(error)
                this.isLoadingNextPage = false
            case let .success(list):
                let zip = DispatchGroup()
                var items = [Identifier : Item]()
                list.page.array.forEach { image in
                    zip.enter()
                    let sizesEndpoint = flickr.getSizes(photoId: image.id)
                    let sizeId = UUID()
                    let sizeTask = session.download(sizesEndpoint) { result in
                        defer { zip.leave() }
                        this.runningTasks[sizeId] = nil
                        switch result {
                        case let .failure(error):
                            error.log()
                        case let .success(sizeInfo):
                            let size = sizeInfo.sizes.preferredSize.size
                            items[image.id] = Item(identifier: image.id,
                                                   url: image.url,
                                                   size: size)
                        }
                    }
                    this.runningTasks[sizeId] = sizeTask
                }
                zip.notify(queue: .main) { [weak self] in
                    guard let this = self else { return }
                    let ids = list.page.array.map { $0.id }
                    this.isLoadingNextPage = false
                    this.update(imageList: list, newItems: items)
                    this.nextPageLoaded?(ids)
                }
            }
        }
        runningTasks[listTaskId] = listTask
    }
}
