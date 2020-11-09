//
//  Item.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import Foundation

struct Item: Codable {
    let id: String
    let itemCount: Int
    let url: URL?
    let type: String
    let metadata: Metadata
    let thumbnail: Thumbnail
    let asset: Asset?
    
    init(id: String, itemCount: Int, url: URL, type: String, metadata: Metadata, thumbnail: Thumbnail, asset: Asset) {
        self.id = id
        self.itemCount = itemCount
        self.url = url
        self.type = type
        self.metadata = metadata
        self.thumbnail = thumbnail
        self.asset = asset
    }
}
