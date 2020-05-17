//
//  ImageListViewModelTests.swift
//  FlickrTests
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import XCTest

class ImageListViewModelTests: XCTestCase {
    
    let flickr = Flickr()
        
    func testHappyPath() {

        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }

        Environment.env.session = gooseTestSession()
        
        /// # Perform Tests
        
        var appendNewPageSuccess: Bool!
        
        var addedIdentifiers: Int = 0
        
        let firstPageExpectation = XCTestExpectation(description: "Load First Page")
        let secondPageExpectation = XCTestExpectation(description: "Load Second Page")
        let thirdPageExpectation = XCTestExpectation(description: "Load Third Page")
            
        viewModel.forError {
            error in XCTFail(error.debugDescription)
        }
        
        viewModel.forNewPage { _ in
            addedIdentifiers += 1
            switch addedIdentifiers {
            case 1:
                firstPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 5)
            case 2:
                secondPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 10)
            case 3:
                thirdPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 15)
            default: fatalError("Unreachable")
            }
        }
        
        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendNewPageSuccess)
        wait(for: [firstPageExpectation], timeout: 2)
        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendNewPageSuccess)
        wait(for: [secondPageExpectation], timeout: 2)
        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendNewPageSuccess)
        wait(for: [thirdPageExpectation], timeout: 2)
        
        (0..<viewModel.numberOfItems).forEach {
            XCTAssertNotNil(viewModel.item(at: $0).size)
        }
        
        viewModel.reset()
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    func testTwoObservers() {
        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }

        Environment.env.session = gooseTestSession()
        
        /// # Perform Tests
                
        let firstObserver = XCTestExpectation(description: "Notify First Observer")
        let secondObserver = XCTestExpectation(description: "Notify Second Observer")
            
        viewModel.forError {
            error in XCTFail(error.debugDescription)
        }
        
        viewModel.forNewPage { _ in
            firstObserver.fulfill()
        }
        
        viewModel.forNewPage { _ in
            secondObserver.fulfill()
        }
        
        viewModel.appendNewPage()
        wait(for: [firstObserver, secondObserver], timeout: 2)
    }
    
    /// Tries to append when there's no more pages left.
    func testAppendBeyondLastPage() {
        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }

        Environment.env.session = gooseTestSession()
        
        /// # Perform Tests
        
        var addedIdentifiers: Int = 0
        var appendNewPageSuccess: Bool!
        
        
        let firstPageExpectation = XCTestExpectation(description: "Load First Page")
        let secondPageExpectation = XCTestExpectation(description: "Load Second Page")
        let thirdPageExpectation = XCTestExpectation(description: "Load Third Page")
            
        viewModel.forError {
            error in XCTFail(error.debugDescription)
        }
        
        viewModel.forNewPage { _ in
            addedIdentifiers += 1
            switch addedIdentifiers {
            case 1:
                firstPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 5)
            case 2:
                secondPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 10)
            case 3:
                thirdPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 15)
            default: fatalError("Unreachable")
            }
        }
        
        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendNewPageSuccess)
        wait(for: [firstPageExpectation], timeout: 2)
        appendNewPageSuccess = viewModel.appendNewPage()
        wait(for: [secondPageExpectation], timeout: 2)
        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendNewPageSuccess)
        wait(for: [thirdPageExpectation], timeout: 2)

        appendNewPageSuccess = viewModel.appendNewPage()
        XCTAssertEqual(viewModel.numberOfItems, 15)
        XCTAssertFalse(appendNewPageSuccess)
    }
    
    /// Makes sure that no more callbacks are made after cancelling an observation.
    func testCanceledObservations() {
        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }

        Environment.env.session = gooseTestSession()
        
        /// # Perform Tests
        
        var addedIdentifiers: Int = 0
        
        let firstPageExpectation = XCTestExpectation(description: "Load First Page")
        let secondPageExpectation = XCTestExpectation(description: "Load Second Page")
            
        viewModel.forError {
            error in XCTFail(error.debugDescription)
        }
        
        let newPageToken = viewModel.forNewPage { _ in
            addedIdentifiers += 1
            switch addedIdentifiers {
            case 1:
                firstPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 5)
            case 2:
                secondPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 10)
            case 3:
                XCTFail("Should not receive a callback due to cancellation.")
            default: fatalError("Unreachable")
            }
        }

        viewModel.appendNewPage()
        wait(for: [firstPageExpectation], timeout: 2)
        viewModel.appendNewPage()
        wait(for: [secondPageExpectation], timeout: 2)
        viewModel.cancelObservation(newPageToken) // 🛑
        viewModel.appendNewPage()
        sleep(1) // Delay to make sure no new page is added.
    }
    
    /// Setting the endpoint source resets the page. Affirm the correct behavior.
    func testSetEndpointSource() {
        let viewModel = ImageListViewModel()
        Environment.env.session = gooseTestSession()
        XCTAssertFalse(viewModel.appendNewPage())
        XCTAssertEqual(viewModel.numberOfItems, 0)
        
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }
        
        var appendPageSuccess: Bool!
        var addedIdentifiers: Int = 0
        
        let firstPageExpectation = XCTestExpectation(description: "Load First Page")
        let secondPageExpectation = XCTestExpectation(description: "Load Second Page")
        let thirdPageExpectation = XCTestExpectation(description: "Load Third Page")
            
        viewModel.forError {
            error in XCTFail(error.debugDescription)
        }
        
        viewModel.forNewPage { _ in
            addedIdentifiers += 1
            switch addedIdentifiers {
            case 1:
                firstPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 5)
            case 2:
                secondPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 10)
            case 3:
                thirdPageExpectation.fulfill()
                XCTAssertEqual(viewModel.numberOfItems, 15)
            default: fatalError("Unreachable")
            }
        }

        appendPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendPageSuccess)
        wait(for: [firstPageExpectation], timeout: 2)
        appendPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendPageSuccess)
        wait(for: [secondPageExpectation], timeout: 2)
        appendPageSuccess = viewModel.appendNewPage()
        XCTAssertTrue(appendPageSuccess)
        wait(for: [thirdPageExpectation], timeout: 2)
        
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 0) }
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    func gooseTestSession() -> TestSession {
        let fm = FileManager.default
        
        let currentBundle = Bundle(for: type(of: self))
        
        let searchFolderURL = URL(fileURLWithPath: currentBundle.resourcePath!)
            .appendingPathComponent("flickr.photos.search.goose", isDirectory: true)
        
        let sizesFolderURL = URL(fileURLWithPath: currentBundle.resourcePath!)
            .appendingPathComponent("flickr.photos.getSize.goose", isDirectory: true)
        
        precondition(fm.fileExists(atPath: searchFolderURL.path))
        precondition(fm.fileExists(atPath: sizesFolderURL.path))

        let imageListSamples: [FlickrList] = decodeTestCases(folder: searchFolderURL).sorted(by: {
            $0.page.pageNumber < $1.page.pageNumber
        })
        
        var imageListEndpoints = [Endpoint<FlickrList>]()
        
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
                let imageSizeInfo: FlickrSizesInfo = json(at: imageSizeURL.path)
                let imageSizeEndpoint = flickr.getSizes(photoId: image.id)
                let imageSizeMockResult = MockResult(endpoint: imageSizeEndpoint, result: .success(imageSizeInfo))
                mockResults.append(imageSizeMockResult)
            }
        }
        
        return TestSession(mockResults: mockResults)
    }
    
}

extension Result {
    
    func testIsSuccess() {
        if case .failure = self { XCTFail() }
    }
    
}
