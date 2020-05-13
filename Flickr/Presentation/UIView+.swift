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
    
}
