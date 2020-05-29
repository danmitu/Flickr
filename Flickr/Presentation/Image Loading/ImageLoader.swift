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
            // TODO: Thread 8: EXC_BAD_ACCESS (code=EXC_I386_GPFLT)
            defer { this.runningRequests.removeValue(forKey: id) }
            switch result {
            case .success(let image):
                self?.loadedImages[url] = image
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }

        }
        runningRequests[id] = dataTask
        return id
    }

    func cancelLoad(_ uuid: UUID) {
      runningRequests[uuid]?.cancel()
      runningRequests.removeValue(forKey: uuid)
    }
    
}

struct ImageError: Error {}

extension Endpoint where A == UIImage {
    init(imageURL: URL) {
        self = Endpoint(.get, url: imageURL) { data, _ in
            Result {
                guard let d = data, let i = UIImage(data: d) else { throw ImageError() }
                return i
            }
        }
    }
}
