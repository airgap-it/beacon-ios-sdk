//
//  MockNetwork.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation
@testable import BeaconCore

public struct MockNetwork: NetworkProtocol {
    public typealias `Type` = String
    
    public let type: `Type`
    public let name: String?
    public let rpcURL: String?
    
    public init(type: `Type`, name: String? = nil, rpcURL: String? = nil) {
        self.type = type
        self.name = name
        self.rpcURL = rpcURL
    }
}
