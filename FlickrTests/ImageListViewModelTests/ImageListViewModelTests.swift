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
        
    private func testHappyPath() {

        let viewModel = ImageListViewModel()
        viewModel.endpointSource = { self.flickr.search(text: "Goose", page: $0, perPage: 5) }

        Environment.env.session = gooseTestSession()
        
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

        viewModel.appendNewPage()
        wait(for: [firstPageExpectation], timeout: 2)
        viewModel.appendNewPage()
        wait(for: [secondPageExpectation], timeout: 2)
        viewModel.appendNewPage()
        wait(for: [thirdPageExpectation], timeout: 2)
        
        (0..<viewModel.numberOfItems).forEach {
            XCTAssertNotNil(viewModel.item(at: $0).size)
        }
        
        viewModel.reset()
        XCTAssertEqual(viewModel.numberOfItems, 0)
    }
    
    private func gooseTestSession() -> TestSession {
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
