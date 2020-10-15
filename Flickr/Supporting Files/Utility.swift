//
//  Utility.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

/// Load a plist from a bundle. Return it as a dictionary.
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

/// Load json from a bundle. Return it as a dictionary.
func json(_ resource: String, bundle: Bundle) -> [String:AnyObject] {
    
    let filename = "\(resource).json"
    
    guard let path: String = bundle.path(forResource: resource, ofType: "json") else {
        fatalError("Could not find \(filename)")
    }
    
    guard let data = FileManager.default.contents(atPath: path) else {
        fatalError("Could not load contents for \(filename)")
    }

    guard let result = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? Dictionary<String, AnyObject> else {
        fatalError("Could not serialize data as a property list for \(filename)")
    }

    return result
}

/// Load json from a bundle and decode it into a type.
func json<T: Decodable>(_ resource: String, bundle: Bundle, inDirectory: String? = nil) -> T {
    
    let filename = "\(resource).json"
    
    guard let path: String = bundle.path(forResource: resource, ofType: "json", inDirectory: inDirectory) else {
        fatalError("Could not find \(filename)")
    }
    
    guard let data = FileManager.default.contents(atPath: path) else {
        fatalError("Could not load contents for \(filename)")
    }

    guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
        fatalError("Failed to decode contents for \(filename)")
    }
    
    return decoded
}

func json<T: Decodable>(at path: String) -> T {
    guard let data = FileManager.default.contents(atPath: path) else {
        fatalError("Could not load contents at \(path)")
    }

    guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
        fatalError("Failed to decode contents at \(path)")
    }
    
    return decoded
}

func decodeTestCases<T: Decodable>(folder url: URL) -> [T] {
    let fileURLs: [URL] = try! FileManager.default.contentsOfDirectory(atPath: url.path).map { url.appendingPathComponent($0) }
    return fileURLs.map { json(at: $0.path) }
}

func pathsInDirectory(folder: String, bundle: Bundle) -> [String] {
    let path = "\(bundle.resourcePath!)/\(folder)"
    let filenames = try! FileManager.default.contentsOfDirectory(atPath: path)
    return filenames.map { filename in "\(path)/\(filename)" }
}

func decodeTestCases<T: Decodable>(folder: String, bundle: Bundle) -> [T] {
    pathsInDirectory(folder: folder, bundle: bundle).map { json(at: $0) }
}

func folderExists(_ name: String, bundle: Bundle) -> Bool {
    let path = "\(bundle.resourcePath!)/\(name)"
    return FileManager.default.fileExists(atPath: path)
}
