//
//  Network.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol NetworkProtocol {
    associatedtype `Type`: Codable & CustomStringConvertible
    
    var type: `Type` { get }
    var name: String? { get }
    var rpcURL: String? { get }
}

// MARK: Extensions

extension NetworkProtocol {
    public var identifier: String {
        var data = [type.description]
        
        if let name = name {
            data.append("name:\(name)")
        }
        
        if let rpcURL = rpcURL {
            data.append("rpc:\(rpcURL)")
        }
        
        return data.joined(separator: "-")
    }
}
