//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Apple on 20/04/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { (error, response) in
            // Later we can parse error type and pass error accordingly
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        }
    }
}
