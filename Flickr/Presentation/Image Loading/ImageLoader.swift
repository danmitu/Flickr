//
//  ImageLoader.swift
//  Flickr
//
//  Source: https://www.donnywals.com/efficiently-loading-images-in-table-views-and-collection-views/
//

import UIKit

/// Loads and maintains a cache of `UIImage`. Requests can be canceled.
class ImageLoader {

    private var session: URLSession!
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()

    private let mutex = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue.global(qos: .userInitiated)
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    @discardableResult
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        if let image = loadedImages[url] {
            completion(.success(image))
            return nil
        }
        
        let endpoint = Endpoint(imageURL: url)
        let id = UUID()
        
        let dataTask = session.load(endpoint) { [weak self] result in
            guard let this = self else { return }
            defer {
                this.queue.async {
                    this.mutex.wait()
                    this.runningRequests.removeValue(forKey: id)
                    this.mutex.signal()
                }
            }
            switch result {
            case .success(let image):
                self?.loadedImages[url] = image
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }

        }
        queue.async {
            self.mutex.wait()
            self.runningRequests[id] = dataTask
            self.mutex.signal()
        }
        
        return id
    }

    func cancelLoad(_ uuid: UUID) {
        queue.async {
            self.mutex.wait()
            self.runningRequests[uuid]?.cancel()
            self.runningRequests.removeValue(forKey: uuid)
            self.mutex.signal()
        }
    }
    
}

struct ImageError: Error {}

extension Endpoint where A == UIImage {
    init(imageURL: URL) {
        self = Endpoint(.get, url: imageURL, cachePolicy: .returnCacheDataElseLoad) { data, _ in
            Result {
                guard let d = data, let i = UIImage(data: d) else { throw ImageError() }
                return i
            }
        }
    }
}
