//
//  ImageListViewController.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

protocol ImageListViewControllerDelegate: class {
    
    func imageListViewConroller(_ imageListViewController: ImageListViewController, push viewController: UIViewController, animated: Bool)
    
}

class ImageListViewController: UICollectionViewController, JustifiedLayoutDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    weak var delegate: ImageListViewControllerDelegate?
    
    init(viewModel: ImageListViewModel) {
        self.viewModel = viewModel
        let layout = JustifiedLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private let viewModel: ImageListViewModel

    typealias Item = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: CaseIterable { case main }
    
    private lazy var dataSource = DataSource(collectionView: collectionView) {
        [weak self] collectionView, indexPath, identifier in
        guard let this = self else { return nil }
        if this.shouldLoadNextPage(given: indexPath) {
            this.viewModel.appendNewPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let url = this.viewModel.item(at: indexPath.item).url
        cell.imageView.loadImage(at: url)
        return cell
    }
    
    func startLoadingPages() {
        startAnimatingActivityIndicator()

        viewModel.appendNewPage()
    }
    
    func reset() {
        viewModel.reset()
        var snapshot = Snapshot()
        if snapshot.numberOfSections == 0 { snapshot.appendSections([.main]) }
        dataSource.apply(snapshot)
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
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPageViewController(for: indexPath.item)
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
        
        viewModel.forNewPage { [weak self] items in
            self?.stopAnimatingActivityIndicator()
            self?.apply(newItems: items)
        }
        
        viewModel.forError { [weak self] error in
            self?.stopAnimatingActivityIndicator()
            self?.presentErrorAlert(error)
        }
        
        // Activity Indicator View
        view.addAndCenterSubView(activityIndicatorView)
        
        // Page View Controller
        pageViewController.delegate = self
        pageViewController.dataSource = self
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
    
    private let fallbackSize = CGSize(width: 100, height: 100)
    
    func collectionView(_ collectionView: UICollectionView, layout: JustifiedLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = viewModel.item(at: indexPath.item).size else { return fallbackSize }
        return CGSize(size: size)
    }
    
    // MARK: - Paged Images
    
    // TODO: Nice little comment explaining how I do this part.
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    /// Uses the view contorller hash value to associate it with an index.
    private var pageIndex = [Int : Int]()
    
    private func presentPageViewController(for index: Int) {
        pageIndex.removeAll() // Reset from a previous session.
        let vc = imageScrollViewController(for: index)!
        pageViewController.setViewControllers([vc],
                                              direction: .forward,
                                              animated: true)
        pageIndex[vc.hashValue] = index
        delegate?.imageListViewConroller(self, push: pageViewController, animated: true)
    }
    
    /// What's the VC when the user swipes left to right?
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pageIndex[viewController.hashValue]!
        let prevIndex = index - 1
        guard let beforeViewController = imageScrollViewController(for: prevIndex) else {
            return nil
        }
        pageIndex[beforeViewController.hashValue] = prevIndex
        return beforeViewController
    }
    
    /// What's the VC when the user swipes right to left?
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pageIndex[viewController.hashValue]!
        let nextIndex = index + 1
        guard let afterViewController = imageScrollViewController(for: nextIndex) else {
            return nil
        }
        pageIndex[afterViewController.hashValue] = nextIndex
        return afterViewController
    }

    /// Returns the view controller individual "page" matching the view model data at a given index.
    private func imageScrollViewController(for index: Int) -> ImageScrollViewController? {
        guard viewModel.indices.contains(index) else { return nil }
        let viewController = ImageScrollViewController()
        let url = viewModel.item(at: index).url
        viewController.loadImage(url)
        return viewController
    }
        
}

