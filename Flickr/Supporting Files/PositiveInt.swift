//
//  PositiveInt.swift
//  Flickr
//
//  Created by Dan Mitu on 5/14/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation

@propertyWrapper
struct PositiveInt {
    private(set) var value: Int = 0

    var wrappedValue: Int {
        get { value }
        set { value = newValue > 0 ? newValue : 0 }
    }

    init(wrappedValue initialValue: Int) {
        self.wrappedValue = initialValue
    }
}

@propertyWrapper
struct OptionalPostiveInt {
    private(set) var value: Int? = 0

    var wrappedValue: Int? {
        get { value }
        set {
            if let someValue = newValue {
                value = someValue > 0 ? newValue : 0
            } else {
                value = nil
            }
        }

    }

    init(wrappedValue initialValue: Int?) {
        self.wrappedValue = initialValue
    }
}
