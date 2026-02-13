//
//  MockIdentifierCreator.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import OctezConnectCore

public struct MockIdentifierCreator: IdentifierCreatorProtocol {
    public init() {}
    
    public func accountID(forAddress address: String, onNetworkWithIdentifier networkIdentifier: String?) throws -> String {
        address
    }
    
    public func senderID(from publicKey: [UInt8]) throws -> String {
        try senderID(from: HexString(from: publicKey))
    }
    
    public func senderID(from publicKey: HexString) throws -> String {
        publicKey.asString()
    }
}
