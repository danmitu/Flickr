//
//  ImageListViewModel.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

/// A paginated list of images where each image size is available.
class ImageListViewModel {
    
    /// Provides the endpoint to update the collection given a page number.
    /// Setting this resets the viewModel.
    var endpointSource: ((Int)->Endpoint<FlickrList>)? { didSet { reset() } }
    
    // MARK: - Initialization
    
    deinit {
        runningTasks.values.forEach { $0.cancel() }
    }
    
    // MARK: - Data
    
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
    
    @PositiveInt private(set) var currentPage = 0
    @OptionalPostiveInt private var numberPages = nil
    @OptionalPostiveInt private var totalImages = nil
    private var isLoadingNextPage = false
    
    private var runningTasks = [UUID:URLSessionTask]()
    
    func reset() {
        currentPage = 0
        numberPages = nil
        totalImages = nil
        identifiers.removeAll()
        items.removeAll()
        runningTasks.values.forEach { $0.cancel() }
        runningTasks.removeAll()
        isLoadingNextPage = false
    }
    
    private func update(imageList: FlickrList, newItems: [Identifier:Item]) {
        identifiers.append(contentsOf: imageList.page.array.map { $0.id })
        items.merge(dict: newItems)
        currentPage = imageList.page.pageNumber
        numberPages = imageList.page.pages
        totalImages = imageList.page.total
        assert(currentPage <= numberPages!)
    }

    var isLastPage: Bool { return currentPage == numberPages }

    // MARK: - Observation
    
    private var observations = (
        pageLoaded: [UUID: ([Identifier])->Void](),
        errorOccurred: [UUID: (Error)->Void]()
    )
    
    @discardableResult
    func forNewPage(_ callback: @escaping ([Identifier])->Void) -> UUID {
        let uuid = UUID()
        observations.pageLoaded[uuid] = callback
        return uuid
    }
    
    @discardableResult
    func forError(_ callback: @escaping (Error)->Void) -> UUID {
        let uuid = UUID()
        observations.errorOccurred[uuid] = callback
        return uuid
    }
    
    func cancelObservation(_ uuid: UUID) {
        observations.pageLoaded[uuid] = nil
        observations.errorOccurred[uuid] = nil
    }
    
    private func notifyObservers(newPages identifiers: [Identifier]) {
        DispatchQueue.main.async {
            self.observations.pageLoaded.values.forEach { $0(identifiers) }
        }
        
    }
    
    private func notifyObservers(error: Error) {
        DispatchQueue.main.async {
            self.observations.errorOccurred.values.forEach { $0(error) }
        }
    }
        
    // MARK: - Load Pages
    
    @discardableResult
    func appendNewPage() -> Bool {
        guard !isLastPage else { return false }
        guard !isLoadingNextPage else { return false }
        guard let endpointSource = endpointSource else { return false }
        isLoadingNextPage = true
        let flickr = Flickr()
        let session = Environment.env.session
        let endpoint = endpointSource(currentPage + 1)
        let listTaskId = UUID()
        /// ** Load List**
        let listTask = session.download(endpoint) { [weak self] result in
            guard let self = self else { return }
            self.runningTasks[listTaskId] = nil
            switch result {
            case let .failure(error):
                self.notifyObservers(error: error)
                self.isLoadingNextPage = false
            case let .success(list):
                // Zips the size for each photo in the list.
                let zip = DispatchGroup()
                var items = [Identifier : Item]()
                let images = list.page.array
                // Make sure an image isn't inserted more than once (e.g. page 1 is loaded, an image from page 1 moves to page 2, then page 2 is loaded)
                let newImages = images.filter { !self.identifiers.contains($0.id) }
                var idsWithSizes = Set<Identifier>()
                /// ** For each image...**
                newImages.forEach { image in
                    zip.enter()
                    let sizesEndpoint = flickr.getSizes(photoId: image.id)
                    let sizeId = UUID()
                    /// ** Load Image Size**
                    let sizeTask = session.download(sizesEndpoint) { result in
                        defer { zip.leave() }
                        self.runningTasks[sizeId] = nil
                        switch result {
                        case let .failure(error):
                            error.log()
                        case let .success(sizeInfo):
                            idsWithSizes.insert(image.id)
                            let size = sizeInfo.sizes.preferredSize.size
                            items[image.id] = Item(identifier: image.id,
                                                   url: image.url,
                                                   size: size)
                        }
                    }
                    self.runningTasks[sizeId] = sizeTask
                }
                zip.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    let ids = list.page.array.map({ $0.id }).filter({ idsWithSizes.contains($0) })
                    self.isLoadingNextPage = false
                    self.update(imageList: list, newItems: items)
                    self.notifyObservers(newPages: ids)
                }
            }
        }
        runningTasks[listTaskId] = listTask
        return true
    }
}

extension ImageListViewModel: Collection {
        
    typealias CollectionType = [Item]
    typealias Index = CollectionType.Index
    typealias Element = CollectionType.Element
    
    var startIndex: Index { return identifiers.startIndex }
    var endIndex: Index { return identifiers.endIndex }

    subscript(index: Index) -> CollectionType.Element {
        get { return item(at: index) }
    }

    func index(after i: Index) -> Index {
        return identifiers.index(after: i)
    }

}
