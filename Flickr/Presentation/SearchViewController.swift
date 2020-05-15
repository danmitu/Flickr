//
//  SearchViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/13/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
  
    private lazy var searchController = UISearchController(searchResultsController: searchResultsViewController)

    private let searchResultsViewController = TextResultsViewController()
    
    private let defaultContentViewController: ImageListViewController = {
        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { Flickr().interesting(page: $0, perPage: 30) }
        return ImageListViewController(viewModel: viewModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(navigationController != nil)
        add(child: defaultContentViewController)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defaultContentViewController.startLoadingPages()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResultsViewController.textQuery = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsViewController.textQuery = searchBar.text ?? ""
    }

    
}
