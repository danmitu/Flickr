//
//  JustifiedLayout.swift
//  Flickr
//
//  Created by Dan Mitu on 5/12/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit

protocol JustifiedLayoutDelegate: class {
 
    func collectionView(_ collectionView: UICollectionView, layout: JustifiedLayout, sizeForItemAt indexPath: IndexPath) -> CGSize

}

class JustifiedLayout: UICollectionViewLayout {
    
    weak var delegate: JustifiedLayoutDelegate!
    
    private var contentBounds = CGRect.zero
    private var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    var spacing: CGFloat = 6 { didSet { invalidateLayout() } }
    
    private var contentWidth: CGFloat {
        let width = collectionView!.bounds.width
        let inset = collectionView!.contentInset
        return width - (inset.left + inset.right)
    }
    
    override func prepare() {
        super.prepare()
        
        guard
            let collectionView = collectionView
            else { return }

        cachedAttributes.removeAll()
        let contentSize = CGSize(width: contentWidth, height: 0)
        contentBounds = CGRect(origin: .zero, size: contentSize)
        
        var verticalOffset: CGFloat = 0
        
        guard collectionView.numberOfSections > 0 else { return }
        let count = collectionView.numberOfItems(inSection: 0)
        var currentIndex = 0
        while currentIndex < count {
            var currentRowSizes = [CGSize]()
            var rowWidthSum = CGFloat.zero
            let rowIndex = currentIndex
            
            while rowWidthSum < contentBounds.width && currentIndex < count {
                let currentIndexPath = IndexPath(item: currentIndex, section: 0)
                
                var currentSize = delegate.collectionView(collectionView,
                                                          layout: self,
                                                          sizeForItemAt: currentIndexPath)
                
                if let firstSize = currentRowSizes.first {
                    let boundingSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                              height: firstSize.height)
                    currentSize = CGSize.aspectFit(aspectRatio: currentSize,
                                                   boundingSize: boundingSize)
                }
                rowWidthSum += currentSize.width
                currentRowSizes.append(currentSize)
                currentIndex += 1
            }
            
            let numberRowImages = CGFloat(currentRowSizes.count - 1)
            let spacingBetweenRowImages = numberRowImages * spacing
            rowWidthSum += spacingBetweenRowImages
            
            let rowAspectRatio = CGSize(width: rowWidthSum,
                                        height: currentRowSizes.first!.height)
            
            let boundingSize = CGSize(width: contentBounds.width,
                                      height: CGFloat.greatestFiniteMagnitude)
            
            let rowSize = CGSize.aspectFit(aspectRatio: rowAspectRatio,
                                           boundingSize: boundingSize)
                        
            let rowOrigin = CGPoint(x: 0,
                                    y: verticalOffset)
            
            let rowFrame = CGRect(origin: rowOrigin, size: rowSize)
            
            var horizontalOffset = CGFloat.zero
            
            for (index, size) in currentRowSizes.enumerated() {
                
                let finalOrigin = CGPoint(x: horizontalOffset,
                                          y: verticalOffset)
                
                let finalSize = CGSize.aspectFit(aspectRatio: size,
                                                 boundingSize: rowSize)

                let finalFrame = CGRect(origin: finalOrigin,
                                        size: finalSize)
                
                let indexPath = IndexPath(item: rowIndex + index,
                                          section: 0)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = finalFrame
                cachedAttributes.append(attributes)
                
                horizontalOffset += finalSize.width
                horizontalOffset += spacing
            }
            
            verticalOffset += rowSize.height
            verticalOffset += spacing
            
            contentBounds = contentBounds.union(rowFrame)
        }
        
    }
        
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }

    // Perform a binary search on the cached attributes array.
    private func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }

    
}

fileprivate extension CGSize {
    static func aspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
        var boundingSize = boundingSize
        let mW = boundingSize.width / aspectRatio.width;
        let mH = boundingSize.height / aspectRatio.height;

        if mH < mW {
            boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if  mW < mH {
            boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return boundingSize;
    }
    
    static func aspectFill(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
        var minimumSize = minimumSize
        let mW = minimumSize.width / aspectRatio.width;
        let mH = minimumSize.height / aspectRatio.height;

        if mH > mW {
            minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width;
        }
        else if mW > mH {
            minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height;
        }
        
        return minimumSize;
    }
}
