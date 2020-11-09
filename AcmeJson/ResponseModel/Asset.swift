//
//  Asset.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/16/20.
//

import Foundation

struct Asset: Codable {
    let url: String?
    let filename: String
    let type: String
    
    init(url: String, filename: String, type: String) {
        self.url = url
        self.filename = filename
        self.type = type 
    }
}
