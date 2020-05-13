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
