//
//  TextResultsViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class TextResultsViewController: ImageListViewController {

    var textQuery: String? {
        didSet {
            reset()
            guard let textQuery = textQuery else { return }
            presenter.search(query: textQuery)
        }
    }
    
    private let presenter: TextSearchPresenter
    
    init() {
        let presenter = TextSearchPresenter()
        self.presenter = presenter
        super.init(presenter: presenter)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
}
