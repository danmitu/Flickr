//
//  IndexPath+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/29/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

extension IndexPath {
    
    var isFirstSection: Bool { section == 0 }
    
    var isFirstItem: Bool { item == 0 }
    
    func incrementingItem() -> IndexPath {
        IndexPath(item: item + 1,
                  section: section)
    }
    
    func decrementingItem() -> IndexPath {
        IndexPath(item: item - 1,
                  section: section)
    }
    
}
