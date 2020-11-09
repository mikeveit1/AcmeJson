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
        guard let path =  URL(string: "https://launchpadapi.\(Config.Config.acme).com/2/items/\(id)\(Config.Config.access)") else { return }
        
        let url = path
        
        do {
            let data = try Data(contentsOf: url)
            completion(data)
        } catch {
            errorHandler(error)
        }
    }
}
