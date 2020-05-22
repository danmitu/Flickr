//
//  OptionalTrimmedString.swift
//  Flickr
//
//  Source: https://nshipster.com/propertywrapper/
//

import Foundation

@propertyWrapper
struct TrimmedString {
    private(set) var value: String = ""

    var wrappedValue: String {
        get {
            return value
        }
        set {
            value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    init(wrappedValue initialValue: String) {
        self.wrappedValue = initialValue
    }
}


@propertyWrapper
struct OptionalTrimmedString {
    private(set) var value: String?

    var wrappedValue: String? {
        get {
            return value
        }
        set {
            if let newValue = newValue {
                value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                value = nil
            }
        }
    }

    init(wrappedValue initialValue: String?) {
        self.wrappedValue = initialValue
    }
}
