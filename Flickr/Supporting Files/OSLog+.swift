//
//  OSLog+.swift
//  Flickr
//
//  Created by Dan Mitu on 5/11/20.
//  Copyright © 2020 Dan Mitu. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let network = OSLog(subsystem: subsystem, category: "network")

}
