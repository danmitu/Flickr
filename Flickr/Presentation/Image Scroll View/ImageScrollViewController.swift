//
//  ImageScrollViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/19/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

protocol ImageScrollViewControllerDelegate: class {
    func didTap(_ imageScrollViewController: ImageScrollViewController)
    func didDoubleTap(_ imageScrollViewController: ImageScrollViewController)
}

/// Display a scrollable image. Cancels any image loading when the view disappears.
class ImageScrollViewController: UIViewController, ImageScrollViewDelegate {
        
    var isFullScreen: Bool = false {
        didSet {
            imageScrollView.scrollView.backgroundColor = isFullScreen ? .black : .systemBackground
            tabBarController?.tabBar.isHidden = isFullScreen
            navigationController?.setNavigationBarHidden(isFullScreen, animated: false)
        }
    }
    
    func loadImage(_ url: URL) {
        imageScrollView.imageView.loadImage(at: url)
    }

    weak var delegate: ImageScrollViewControllerDelegate?
        
    private let imageScrollView = ImageScrollView()
    
    override func loadView() {
        self.view = imageScrollView
        imageScrollView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageScrollView.imageView.cancelImageLoad()
    }
    
    // MARK: - ImageScrollViewDelegate
    
    /// Does nothing by default.
    func didTap(_ imageScrollView: ImageScrollView) {
        delegate?.didTap(self)
    }
    
    /// Zooms out to display the entire photo.
    func didDoubleTap(_ imageScrollView: ImageScrollView) {
        imageScrollView.zoomOutToFrame()
        delegate?.didDoubleTap(self)
    }
    
    /// Does nothing by default.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {}
    
    /// Does nothing by default.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    
}
