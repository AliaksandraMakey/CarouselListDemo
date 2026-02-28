//
//  MockURLProtocol.swift
//  CarouselListDemoTests
//
//  Created by Alexandra Homan
//

import Foundation

final class MockURLProtocol: URLProtocol {

    static var mockResponse: (data: Data?, response: HTTPURLResponse?, error: Error?)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let mock = Self.mockResponse else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock configured"]))
            return
        }
        if let error = mock.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = mock.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = mock.data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
