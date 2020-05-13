//
//  UIViewController+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/12/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

extension UIViewController {

    func presentErrorAlert(_ error: Error, onConfirmation: (()->Void)? = nil) {
        let alertController = UIAlertController(title: "Error",
                                                message: error.description,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            onConfirmation?()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

}

/// For adding and removing child view controllers.
@nonobjc extension UIViewController {
    func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func removeChild() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
