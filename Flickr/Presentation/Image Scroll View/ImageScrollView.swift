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
class ImageScrollView: UIView {
    
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
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        singleTapGesture.require(toFail: doubleTapGesture)
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(singleTapGesture)
        scrollView.addGestureRecognizer(doubleTapGesture)
        scrollView.delegate = self
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            ])
    }
    
    @objc func didTap() {
        delegate?.didTap(self)
    }
    
    @objc func didDoubleTap() {
        delegate?.didDoubleTap(self)
    }
    
    func zoomOutToFrame() {
        scrollView.zoom(to: imageView.frame, animated: true)
    }
    
}

extension ImageScrollView: UIScrollViewDelegate {
    
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
