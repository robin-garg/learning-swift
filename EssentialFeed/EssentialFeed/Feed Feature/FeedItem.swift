//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Apple on 19/04/22.
//

import Foundation

struct FeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
}