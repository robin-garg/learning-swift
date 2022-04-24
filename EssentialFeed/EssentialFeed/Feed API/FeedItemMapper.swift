//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Apple on 24/04/22.
//

import Foundation

internal final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, url: image)
        }
    }
    
    internal static func map(_ data: Data, _ respones: HTTPURLResponse) throws -> [FeedItem] {
        guard respones.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
