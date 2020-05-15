//
//  TextResultsViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

class TextResultsViewController: ImageListViewController {
    
    @OptionalTrimmedString var textQuery: String? {
        didSet {
            guard let textQuery = textQuery else { reset(); return }
            viewModel.search(query: textQuery)
        }
    }
    
    private let viewModel: TextSearchViewModel
    
    init() {
        let viewModel = TextSearchViewModel()
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
}
