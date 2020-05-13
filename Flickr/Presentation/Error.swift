//
//  Error.swift
//  Flickr
//
//  Created by Dan Mitu on 5/7/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation
import os.log

extension Error {
    
    func log() {
        guard shouldLog else { return }
        switch self {
        case let flickrError as FlickrError:
            os_log("Flickr API Error code: %{PUBLIC}@", log: OSLog.network, type: .default, flickrError.code)
        default:
            os_log("%{PUBLIC}@", log: OSLog.network, type: .default, debugDescription)
        }
    }
    
    private var shouldLog: Bool {
        // By default, I log the errors but there are some I do not care about.
        switch self {
        case let nsError as NSError:
            switch nsError.code {
            case NSURLErrorCancelled: return false
            default: break
            }
        default: break
        }
        return true
    }
    
    // This is what I see.
    var debugDescription: String {
        switch self {
        case let error as FlickrError:
            return "Flickr API Error: (\(error.code)) \(error.message)"
        case is NoDataError:
            return "No Data Error"
        case let wrongStatusCodeError as WrongStatusCodeError:
            return "Wrong Status Code Error: (\(wrongStatusCodeError.statusCode))."
        case let nsError as NSError:
            return nsError.debugDescription
        default:
            return "Unkown Error"
        }
    }
    
    // This is what users see. In the future, it may be more descriptive.
    var description: String {
        return "There was an error."
    }
    
}
