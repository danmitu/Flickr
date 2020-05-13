//
//  TrimmedString.swift
//  Flickr
//
//  Source: https://nshipster.com/propertywrapper/
//

import Foundation

@propertyWrapper
struct TrimmedString {
    private(set) var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    init(wrappedValue initialValue: String) {
        self.wrappedValue = initialValue
    }
}
