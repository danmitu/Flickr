//
//  Session.swift
//  FlickrClient
//
//  Source: https://talk.objc.io/episodes/S01E137-testing-networking-code
//

import Foundation

struct Environment {
    var session: Session = URLSession.shared
    static var env = Environment()
}

protocol Session {
    
    func download<A>(_ endpoint: Endpoint<A>, onComplete: @escaping (Result<A, Error>)->())
    
}

extension URLSession: Session {
    
    func download<A>(_ endpoint: Endpoint<A>, onComplete: @escaping (Result<A, Error>) -> ()) {
        load(endpoint, onComplete: onComplete)
    }
    
}
