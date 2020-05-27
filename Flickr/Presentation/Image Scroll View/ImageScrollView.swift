//
//  ImageScrollView.swift
//  Flickr
//
//  Created by Dan Mitu on 5/19/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

protocol ImageScrollViewDelegate: class {
    
    func didTap(_ imageScrollView: ImageScrollView)
    func didDoubleTap(_ imageScrollView: ImageScrollView)
    func scrollViewDidZoom(_ scrollView: UIScrollView)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    
}

/// Display an image that you can pinch to zoom, drag to pan, double tap to zoom out, and single tap to do whatever.
class ImageScrollView: UIView, UIScrollViewDelegate {
    
    weak var delegate: ImageScrollViewDelegate?
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumZoomScale = 1
        view.maximumZoomScale = 5
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.accessibilityIgnoresInvertColors = true
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        scrollView.backgroundColor = .systemBackground
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        singleTapGesture.require(toFail: doubleTapGesture)
        doubleTapGesture.numberOfTapsRequired = 2
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addGestureRecognizer(singleTapGesture)
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        scrollView.anchorSidesToSuperView()
        imageView.anchorCenterToSuperView()
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            ])
    }
    
    @objc func didTap() {
        delegate?.didTap(self)
    }
    
    @objc func didDoubleTap() {
        delegate?.didDoubleTap(self)
    }
    
    func zoomOutToFrame() {
        scrollView.setZoomScale(1, animated: true)
    }
    
    // MARK: - ScrollViewDelegate
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidZoom(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
