//
//  OptionalTrimmedString.swift
//  Flickr
//
//  Source: https://nshipster.com/propertywrapper/
//

import Foundation

@propertyWrapper
struct OptionalTrimmedString {
    private(set) var value: String?

    var wrappedValue: String? {
        get { value }
        set {
            if let newValue = newValue {
                value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    init(wrappedValue initialValue: String?) {
        self.wrappedValue = initialValue
    }
}
