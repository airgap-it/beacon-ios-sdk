//
//  MockIdentifierCreator.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore

public struct MockIdentifierCreator: IdentifierCreatorProtocol {
    public init() {}
    
    public func accountID(forAddress address: String, onNetworkWithIdentifier networkIdentifier: String?) throws -> String {
        address
    }
    
    public func senderID(from publicKey: HexString) throws -> String {
        publicKey.asString()
    }
}
