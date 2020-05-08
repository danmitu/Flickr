//
//  TestSession.swift
//  FlickrClient
//
//  Source: https://talk.objc.io/episodes/S01E137-testing-networking-code
//

import Foundation

/**
How to test...
1. Create a test session with mock results for a given endpoint.
2. Set the Environment session to a given test session.
3. Perform all network requests with the environment session.
4. Use `testSession.verify()` to verify that all the resuts were checked.
*/

/// An endpoint associated with an expected response.
struct MockResult {
    let endpoint: Endpoint<Any>
    let result: Result<Any, Error>
    
    init<A>(endpoint: Endpoint<A>, result: Result<A, Error>) {
        self.endpoint = endpoint.map { $0 }
        switch result {
        case let .success(x): self.result = .success(x as Any)
        case let .failure(e): self.result = .failure(e)
        }
    }
}

class TestSession: Session {
    
    private var mockResults: [MockResult] = []
    
    init(mockResults: [MockResult]) {
        self.mockResults = mockResults
    }

    /// Removes the `MockResult` every time it's found.
    func download<A>(_ endpoint: Endpoint<A>, onComplete: @escaping (Result<A, Error>) -> ()) {
        /// Searches the mock responses for an endpoint match. Make sure it's the right type too.
        guard let index = mockResults.firstIndex(where: { $0.endpoint.request == endpoint.request }) else {
            fatalError("No such endpoint: \(endpoint.request.url!.absoluteString)")
        }
        let mockResult = mockResults[index]
        switch mockResult.result {
        case let .success(x):
            guard let x = x as? A else {
                fatalError("Endpoint type and MockResult type do not match: \(endpoint.request.url!.absoluteString)")
            }
            mockResults.remove(at: index)
            onComplete(.success(x))
        case let .failure(e):
            mockResults.remove(at: index)
            onComplete(.failure(e))
        }
    }
    
    /// Verifies that there are no remaining mock results. Returns true if successful.
    func verify() -> Bool {
        return mockResults.isEmpty
    }
    
}
