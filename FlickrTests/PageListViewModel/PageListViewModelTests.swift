//
//  PageListViewModelTests.swift
//  FlickrTests
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import UIKit
import XCTest
@testable import Flickr

class PageListViewModelTests: XCTestCase {

    let flickr = Flickr()
        
    var viewModel = PagedListViewModel()
    
    /// Tests the basic functionality of the paged list view-model.
    func testNextPage() {
        
        /// # Prepare Tests
        
        let fm = FileManager.default
        
        let currentBundle = Bundle(for: type(of: self))
        
        let searchFolderURL = URL(fileURLWithPath: currentBundle.resourcePath!)
            .appendingPathComponent("flickr.photos.search.goose", isDirectory: true)
        
        let sizesFolderURL = URL(fileURLWithPath: currentBundle.resourcePath!)
            .appendingPathComponent("flickr.photos.getSize.goose", isDirectory: true)
        
        precondition(fm.fileExists(atPath: searchFolderURL.path))
        precondition(fm.fileExists(atPath: sizesFolderURL.path))

        let imageListSamples: [ImageList] = decodeTestCases(folder: searchFolderURL).sorted(by: {
            $0.page.page < $1.page.page
        })
        
        var imageListEndpoints = [Endpoint<ImageList>]()
        
        var mockResults = [MockResult]()
        
        for (n, imageList) in imageListSamples.enumerated() {

            let imageListEndpoint = flickr.search(text: "Goose",
                                                  page: n + 1,
                                                  perPage: imageList.page.perPage)
            
            imageListEndpoints.append(imageListEndpoint)

            let imageListMockResult = MockResult(endpoint: imageListEndpoint,
                                                 result: .success(imageList))

            mockResults.append(imageListMockResult)

            for image in imageList.page.array {
                let imageSizeFilename = "flickr.photos.getSizes.\(image.id)"
                let imageSizeURL = sizesFolderURL.appendingPathComponent(imageSizeFilename).appendingPathExtension("json")
                let imageSizeInfo: ImageSizeInfo = json(at: imageSizeURL.path)
                let imageSizeEndpoint = flickr.getSizes(photoId: image.id)
                let imageSizeMockResult = MockResult(endpoint: imageSizeEndpoint, result: .success(imageSizeInfo))
                mockResults.append(imageSizeMockResult)
            }
        }

        let testSession = TestSession(mockResults: mockResults)
        Environment.env.session = testSession
        
        /// # Perform Tests
        
        var addedIdentifiers: Int = 0
        
        let firstPageExpectation = XCTestExpectation(description: "Load First Page")
        let secondPageExpectation = XCTestExpectation(description: "Load Second Page")
        let thirdPageExpectation = XCTestExpectation(description: "Load Third Page")
                
        viewModel.errorOccurred = { error in XCTFail(error.debugDescription) }
        
        viewModel.nextPageLoaded = { _ in
            addedIdentifiers += 1
            switch addedIdentifiers {
            case 1:
                firstPageExpectation.fulfill()
                XCTAssertEqual(self.viewModel.numberOfItems, 5)
            case 2:
                secondPageExpectation.fulfill()
                XCTAssertEqual(self.viewModel.numberOfItems, 10)
            case 3:
                thirdPageExpectation.fulfill()
                XCTAssertEqual(self.viewModel.numberOfItems, 15)
            default: fatalError("Unreachable")
            }
        }

        viewModel.load(imageListEndpoints[0])
        wait(for: [firstPageExpectation], timeout: 2)
        viewModel.append(imageListEndpoints[1])
        wait(for: [secondPageExpectation], timeout: 2)
        viewModel.append(imageListEndpoints[2])
        wait(for: [thirdPageExpectation], timeout: 2)
        
        (0..<viewModel.numberOfItems).forEach {
            XCTAssertNotNil(viewModel.size(at: $0 ))
        }
        
        viewModel.reset()
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
        
}

extension Result {
    
    func testIsSuccess() {
        if case .failure = self { XCTFail() }
    }
    
}
