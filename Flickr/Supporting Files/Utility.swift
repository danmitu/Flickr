//
//  Utility.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

/// Load a plist from the main bundle. Return it as a dictionary.
func propertyList(_ resource: String, bundle: Bundle) -> [String:AnyObject] {

    let filename = "\(resource).plist"
    
    var format =  PropertyListSerialization.PropertyListFormat.xml
    
    guard let path: String = bundle.path(forResource: resource, ofType: "plist") else {
        fatalError("Could not find \(filename)")
    }
    
    guard let data = FileManager.default.contents(atPath: path) else {
        fatalError("Could not load contents at \(filename)")
    }
    
    guard let plist: [String:AnyObject] = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String:AnyObject] else {
        fatalError("Could not serialize data as a property list for \(filename)")
    }

    return plist
}
