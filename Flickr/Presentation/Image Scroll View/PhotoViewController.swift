//
//  PhotoViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/19/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

/// Display a scrollable image. Cancels any image loading when the view disappears.
class PhotoViewController: UIViewController {
    
    func loadImage(_ url: URL) {
        imageScrollView.imageView.loadImage(at: url)
    }
    
    private let imageScrollView = PhotoView()
    
    override func loadView() {
        self.view = imageScrollView
        imageScrollView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageScrollView.imageView.cancelImageLoad()
    }
    
}

extension PhotoViewController: PhotoViewDelegate {
    
    /// Does nothing by default.
    func didTap(_ imageScrollView: PhotoView) {}
    
    /// Zooms out to display the entire photo.
    func didDoubleTap(_ imageScrollView: PhotoView) {
        imageScrollView.zoomOutToFrame()
    }
    
    /// Does nothing by default.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {}
    
    /// Does nothing by default.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    
}

