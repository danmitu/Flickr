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
    
    var debugDescription: String {
        switch self {
            case let error as FlickrError:
                return "Flickr API Error: (\(error.code)) \(error.message)"
            case is NoDataError:
                return "No Data Error"
            case let wrongStatusCodeError as WrongStatusCodeError:
                return "Wrong Status Code Error: (\(wrongStatusCodeError.statusCode))."
            case let oldError as NSError:
                return oldError.debugDescription
            default:
                return "Unkown Error"
        }
    }
    
    func log() {
        switch self {
        case let flickrError as FlickrError:
            os_log("Flickr API Error code: %{PUBLIC}@", log: OSLog.network, type: .default, flickrError.code)
        default:
            os_log("%{PUBLIC}@", log: OSLog.network, type: .default, debugDescription)
        }
    }

    var description: String {
        return "There was an error."
    }

}
