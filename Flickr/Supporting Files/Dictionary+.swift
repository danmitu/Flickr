//
//  Dictionary+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/8/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
