//
//  Response.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import Foundation

struct Response:Codable {
    let items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
}
