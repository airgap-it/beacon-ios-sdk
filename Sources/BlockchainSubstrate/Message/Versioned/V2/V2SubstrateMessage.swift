//
//  V2SubstrateMessage.swift
//
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public struct V2SubstrateMessage: BlockchainV2Message {
    public var id: String { "" }
    public var type: String { "" }
    public var version: String { "" }
    
    public init(from beaconMessage: BeaconMessage<Substrate>, senderID: String) throws {
        throw Beacon.Error.messageVersionNotSupported(version: "2", blockchainIdentifier: Substrate.identifier)
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        completion(.failure(Beacon.Error.messageVersionNotSupported(version: "2", blockchainIdentifier: Substrate.identifier)))
    }
}
