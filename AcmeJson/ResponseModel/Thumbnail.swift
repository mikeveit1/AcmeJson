//
//  Thumbnail.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import Foundation

struct Thumbnail: Codable {
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
}
