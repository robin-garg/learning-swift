//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Apple on 19/04/22.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
