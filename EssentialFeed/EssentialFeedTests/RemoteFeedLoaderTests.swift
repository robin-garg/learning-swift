//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 19/04/22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedUrl: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    // we are starting from very simple test. Where we are asseting that we didn't make a URL request on RemoteFeedLoader initalisation. That should only be called when we hit the load function
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedUrl)
    }
}
