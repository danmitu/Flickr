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

class ImageListViewController: UICollectionViewController, JustifiedLayoutDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, ImageScrollViewControllerDelegate {
    
    weak var delegate: ImageListViewControllerDelegate?
        
    init(presenter: ImageListPresenter) {
        self.presenter = presenter
        let layout = JustifiedLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private let presenter: ImageListPresenter

    typealias Item = String
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: CaseIterable { case main }
    
    private lazy var dataSource = DataSource(collectionView: collectionView) {
        [weak self] collectionView, indexPath, identifier in
        guard let self = self else { return nil }
        if self.shouldLoadNextPage(given: indexPath) {
            self.presenter.appendNewPage()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let url = self.presenter.item(at: indexPath.item).url
        cell.imageView.loadImage(at: url)
        return cell
    }
    
    func startLoadingPages() {
        startAnimatingActivityIndicator()
        presenter.appendNewPage()
    }
    
    func reset() {
        presenter.reset()
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
        selectedIndexPath = indexPath
        presentPageViewController(startingIndexPath: indexPath)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection View
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        collectionView.isUserInteractionEnabled = true
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        
        // Presenter
        
        presenter.forNewPage { [weak self] items in
            self?.stopAnimatingActivityIndicator()
            self?.apply(newItems: items)
        }
        
        presenter.forError { [weak self] error in
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
        guard dataSource.snapshot().numberOfItems <= 0 else { return }
        activityIndicatorView.startAnimating()
    }
    
    private func stopAnimatingActivityIndicator() {
        activityIndicatorView.stopAnimating()
    }

    // MARK: - JustifiedLayoutDelegate
    
    private let fallbackSize = CGSize(width: 100, height: 100)
    
    func collectionView(_ collectionView: UICollectionView, layout: JustifiedLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let size = presenter.item(at: indexPath.item).size else { return fallbackSize }
        return CGSize(size: size)
    }
    
    // MARK: - ImageScrollViewDelegate
    
    /// The setting for all the paged view controllers.
    private var isFullScreen = false {
        didSet {
            pageViewController.viewControllers?.forEach {
                ($0 as! ImageScrollViewController).isFullScreen = isFullScreen
            }
        }
    }
    
    func didTap(_ imageScrollViewController: ImageScrollViewController) {
        isFullScreen = !isFullScreen
    }

    func didDoubleTap(_ imageScrollViewController: ImageScrollViewController) {
        isFullScreen = !isFullScreen
    }
    
    
    // MARK: - Paging (UIPageViewControllerDataSource & UIPageViewControllerDelegate)
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    private var selectedIndexPath: IndexPath!

    /// Set between transitions
    private var nextIndexPath: IndexPath!
    
    /// Maps a view controller's hash value to it's index path
    private var viewControllerIndices = [Int : IndexPath]()
    
    private func indexPath(of viewController: UIViewController) -> IndexPath {
        viewControllerIndices[viewController.hashValue]!
    }
    
    /// Returns a new `ImageScrollViewController` representing the item at the presenter `indexPath`.
    private func imageScrollViewController(for indexPath: IndexPath) -> ImageScrollViewController {
        let newViewController = ImageScrollViewController()
        let url = presenter.item(at: indexPath.item).url
        newViewController.loadImage(url)
        newViewController.isFullScreen = isFullScreen
        newViewController.delegate = self
        viewControllerIndices[newViewController.hashValue] = indexPath
        return newViewController
    }

    private func presentPageViewController(startingIndexPath: IndexPath) {
        pageViewController.view.backgroundColor = .systemBackground
        pageViewController.setViewControllers(
            [imageScrollViewController(for: startingIndexPath)],
            direction: .forward,
            animated: true)
        delegate?.imageListViewConroller(self, push: pageViewController, animated: true)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let indexPathOfViewController = indexPath(of: viewController)
        guard indexPathOfViewController.isFirstItem == false else { return nil }
        return imageScrollViewController(for: indexPathOfViewController.decrementingItem())
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return imageScrollViewController(for: indexPath(of: viewController).incrementingItem())
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let nextViewController = pendingViewControllers.first as! ImageScrollViewController
        nextIndexPath = indexPath(of: nextViewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        selectedIndexPath = nextIndexPath
        nextIndexPath = nil
    }
}

