//
//  SingleImageLoader.swift
//  Flickr
//

import UIKit

/// Singleton that handles image loading and caching for the entire app. Can load images directly into a `UIImageView`.
class SingleImageLoader {
    
    // MARK: - Singleton
    
    static let shared = SingleImageLoader()
    
    private init() {}
    
    // MARK: -
    
    private let imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()

    func load(_ url: URL) {
        imageLoader.loadImage(url) { _ in return }
    }
    
    func load(_ url: URL, for imageView: UIImageView) {
        let token = imageLoader.loadImage(url) { r in
            defer { self.uuidMap.removeValue(forKey: imageView) }
            switch r {
            case .success(let image):
                DispatchQueue.main.async {
                    imageView.image = image
                }
            case .failure(let error):
                error.log()
            }
        }
        uuidMap[imageView] = token
    }

    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
          imageLoader.cancelLoad(uuid)
          uuidMap.removeValue(forKey: imageView)
        }
    }
    
}

/**
 Convenience methods for loading an image from a URL directly into a `UIImageView`.
 */

extension UIImageView {
  func loadImage(at url: URL) {
    SingleImageLoader.shared.load(url, for: self)
  }

  func cancelImageLoad() {
    SingleImageLoader.shared.cancel(for: self)
  }
}
