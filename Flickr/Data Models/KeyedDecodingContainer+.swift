//
//  KeyedDecodingContainer+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    
    /// Decodes an `Int` into a `Bool` where even is `false` and odd is `true`.
    func decodeBoolFromInt(forKey key: Key) throws -> Bool {
        let int = try decode(Int.self, forKey: key)
        switch(int % 2) {
        case 0: return false
        case 1: return true
        default: fatalError("Unreachable")
        }
    }
    
    /// Decodes into an `Int`, but also checks for a `String`.
    func decodeIntMaybeString(forKey key: Key) throws -> Int {
        if let str = try? decode(String.self, forKey: key), let int = Int(str) {
          return int
        } else {
          return try decode(Int.self, forKey: key)
        }
    }
    
    /// Decodes into an `String`, but also checks for an `Int`.
    func decodeStringMaybeInt(forKey key: Key) throws -> String {
        if let int = try? decode(Int.self, forKey: key) {
            return "\(int)"
        } else {
            return try decode(String.self, forKey: key)
        }
    }
    
    /// Decodes into an `Double`, but also checks for a `String`.
    func decodeDoubleMaybeString(forKey key: Key) throws -> Double {
        if let str = try? decode(String.self, forKey: key), let double = Double(str) {
          return double
        } else {
          return try decode(Double.self, forKey: key)
        }
    }
    
}
