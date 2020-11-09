//
//  AcmeResponse.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/15/20.
//

import Foundation

struct AcmeResponse: Codable {
    let success: Bool
    let response: Response?

    init(response: Response, success: Bool) {
        self.response = response
        self.success = success
    }
}
