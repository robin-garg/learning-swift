//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 19/04/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedUrl = URL(string: "https://some-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedUrl: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    // we are starting from very simple test. Where we are asseting that we didn't make a URL request on RemoteFeedLoader initalisation. That should only be called when we hit the load function
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
