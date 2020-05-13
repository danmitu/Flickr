//
//  SearchViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/13/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @OptionalTrimmedString private var searchBarInput: String? {
        didSet {
            searchResultsViewController.textQuery = searchBarInput
        }
    }
    
    private lazy var searchController = UISearchController(searchResultsController: searchResultsViewController)
    
    private let searchResultsViewController = TextQueryViewController()
    
    // Could easily be made reuseable, but for now I'll default to Interesting.
    private let defaultContentViewController: UIViewController = InterestingViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(navigationController != nil)
        add(child: defaultContentViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarInput = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarInput = searchBar.text ?? ""
    }

    
}
