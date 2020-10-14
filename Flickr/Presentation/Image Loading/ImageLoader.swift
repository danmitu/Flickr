//
//  ImageLoader.swift
//  Flickr
//

import UIKit

/// Keeps track of the currently running image requests and limits
class ImageLoader {

    private var session: URLSession!
    private var runningIds = [URLRequest: UUID]()
    private var runningTasks = [UUID: URLSessionDataTask]()

    private let mutex = DispatchSemaphore(value: 1)
    private let queue = DispatchQueue.global(qos: .userInitiated)
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    @discardableResult
    func loadImage(_ url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> UUID? {
        let endpoint = Endpoint(imageURL: url)
        let request = endpoint.request
        
        guard runningIds[request] == nil else { return nil }
       
        let id = UUID()

        let dataTask = session.load(endpoint) { [weak self] result in
            guard let self = self else { return }
            defer {
                self.queue.async {
                    self.mutex.wait()
                    self.runningIds.removeValue(forKey: request)
                    self.runningTasks.removeValue(forKey: id)
                    self.mutex.signal()
                }
            }
            completion(result)
        }
        queue.async {
            self.mutex.wait()
            self.runningIds[request] = id
            self.runningTasks[id] = dataTask
            self.mutex.signal()
        }
        
        return id
    }

    func cancelLoad(_ uuid: UUID) {
        queue.async {
            self.mutex.wait()
            self.runningTasks[uuid]?.cancel()
            self.runningTasks.removeValue(forKey: uuid)
            self.mutex.signal()
        }
    }
    
}

struct ImageError: Error {}

extension Endpoint where A == UIImage {
    /// Creates a `Endpoint<UIImage>` with an explicit cache policy of `returnCacheDataElseLoad`.
    init(imageURL: URL) {
        self = Endpoint(.get, url: imageURL, cachePolicy: .returnCacheDataElseLoad) { data, _ in
            Result {
                guard let d = data, let i = UIImage(data: d) else { throw ImageError() }
                return i
            }
        }
    }
}
