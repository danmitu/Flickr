//
//  UIView+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/12/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

extension UIView {
    
    func addAndCenterSubView(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            subview.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
    }
    
    func anchorSidesToSuperView() {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview!.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview!.trailingAnchor),
            topAnchor.constraint(equalTo: superview!.topAnchor),
            bottomAnchor.constraint(equalTo: superview!.bottomAnchor),
        ])
    }
    
    func anchorCenterToSuperView() {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview!.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview!.centerYAnchor),
        ])
    }
    
}

