//
//  DataService.swift
//  AcmeJson
//
//  Created by Michael Veit on 10/16/20.
//

import Foundation

class DataService {
    
    static let shared = DataService()
    
    func getData(id: String, completion: (Data) -> Void, errorHandler: (Error) -> Void) {
        guard let path =  URL(string: "https://launchpadapi.mediafly.com/2/items/\(id)?productId=8049e873d1bf4725bccf362395391810&accessToken=e3464dec016648149c1c4c3ad4888d16&accessType=view") else { return }
        
        let url = path
        
        do {
            let data = try Data(contentsOf: url)
            completion(data)
        } catch {
            errorHandler(error)
        }
    }
}
