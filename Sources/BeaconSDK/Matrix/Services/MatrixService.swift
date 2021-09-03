//
//  MatrixService.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

protocol MatrixService {}

extension MatrixService {
    func apiURL(from node: String, at path: String? = nil) throws -> URL {
        let url = try apiBase(from: node).appendingPathComponent(Beacon.Configuration.matrixClientAPIVersion)
        
        guard let path = path else {
            return url
        }
        
        return url.appendingPathComponent(path)
    }
    
    func apiBase(from node: String, at path: String? = nil) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = node
        urlComponents.path = Beacon.Configuration.matrixClientAPIBase
        
        guard let url = urlComponents.url else {
            throw Beacon.Error.invalidURL(urlComponents.description)
        }
        
        guard let path = path else {
            return url
        }
        
        return url.appendingPathComponent(path)
    }
}
