//
//  ImageScrollViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/19/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

/// Display a scrollable image. Cancels any image loading when the view disappears.
class ImageScrollViewController: UIViewController {
    
    func loadImage(_ url: URL) {
        imageScrollView.imageView.loadImage(at: url)
    }
    
    private let imageScrollView = ImageScrollView()
    
    override func loadView() {
        self.view = imageScrollView
        imageScrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            print(self.imageScrollView.imageView.frame)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageScrollView.imageView.cancelImageLoad()
    }
    
}

extension ImageScrollViewController: ImageScrollViewDelegate {
    
    /// Does nothing by default.
    func didTap(_ imageScrollView: ImageScrollView) {}
    
    /// Zooms out to display the entire photo.
    func didDoubleTap(_ imageScrollView: ImageScrollView) {
        imageScrollView.zoomOutToFrame()
    }
    
    /// Does nothing by default.
    func scrollViewDidZoom(_ scrollView: UIScrollView) {}
    
    /// Does nothing by default.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    
}

