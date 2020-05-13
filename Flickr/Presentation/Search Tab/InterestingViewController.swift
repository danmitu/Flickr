//
//  InterestingViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/12/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

class InterestingViewController: UICollectionViewController, JustifiedLayoutDelegate {

    private let searchController = UISearchController()

    // MARK: - View Model
    
    private let viewModel = InterestingViewModel()
    
    // MARK: - Diffable Data Source
    
    typealias Item = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: CaseIterable { case main }
    
    private lazy var dataSource = DataSource(collectionView: collectionView) {
        [weak self] collectionView, indexPath, identifier in
        guard let this = self else { return nil }
        if this.shouldLoadNextPage(given: indexPath) {
            this.viewModel.loadNextPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        // TODO: Load image for cell here.
        return cell
    }
    
    private func apply(newItems items: [Item]) {
        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 { snapshot.appendSections([.main]) }
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private var firstIndex: IndexPath! {
        guard dataSource.snapshot().numberOfItems > 0 else { return nil }
        return IndexPath(item: 0, section: 0)
    }

    private var lastIndex: IndexPath! {
        let count = dataSource.snapshot().numberOfItems
        guard count > 0 else { return nil }
        return IndexPath(item: count - 1, section: 0)
    }

    
    private func shouldLoadNextPage(given indexPath: IndexPath) -> Bool {
        return indexPath == lastIndex && indexPath != firstIndex
    }
    
    // MARK: - Initialization
    
    init() {
        let layout = JustifiedLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        collectionView.isUserInteractionEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        
        // View Model
        viewModel.nextPageLoaded = { [weak self] items in
            self?.stopAnimatingActivityIndicator()
            self?.apply(newItems: items)
        }
        viewModel.errorOccurred = { [weak self] error in
            self?.stopAnimatingActivityIndicator()
            self?.presentErrorAlert(error)
        }
    
        // Activity Indicator View
        view.addAndCenterSubView(activityIndicatorView)
        
        // Final Actions
        startAnimatingActivityIndicator()
        viewModel.loadNextPage()
    }

    // MARK: - Activity Indicator
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    private func startAnimatingActivityIndicator() {
        guard dataSource.snapshot().numberOfItems > 0 else { return }
        activityIndicatorView.startAnimating()
    }
    
    private func stopAnimatingActivityIndicator() {
        activityIndicatorView.stopAnimating()
    }

    // MARK: - JustifiedLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout: JustifiedLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(size: viewModel.size(at: indexPath.item))
    }
        
}
