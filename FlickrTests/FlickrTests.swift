//
//  FlickrTests.swift
//  FlickrTests
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import XCTest
@testable import Flickr

class FlickrTests: XCTestCase {

    func testReadPropertyList() throws {
        let plist = propertyList("APIKeys", bundle: Bundle.main)
        let apiKey = plist["Flickr"]
        XCTAssertNotNil(apiKey)
    }
    
}
