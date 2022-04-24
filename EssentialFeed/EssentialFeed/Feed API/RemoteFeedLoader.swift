//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Apple on 20/04/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
     
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            // Later we can parse error type and pass error accordingly
            switch result {
            case let .success(data, response):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
//                or we can also use do catch
//                do {
//                    let items = try FeedItemsMapper.map(data, response)
//                    completion(.success(items))
//                } catch {
//                    completion(.failure(.invalidData))
//                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
