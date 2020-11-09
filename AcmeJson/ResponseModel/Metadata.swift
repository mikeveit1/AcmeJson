//
//  Metadata.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import Foundation

struct Metadata: Codable {
    let id: String?
    let title: String?
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
