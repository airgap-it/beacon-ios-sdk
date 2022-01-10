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
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        throw Beacon.Error.messageVersionNotSupported(version: "2", blockchainIdentifier: Substrate.identifier)
    }
    
    public func toBeaconMessage<T: Blockchain>(with origin: Beacon.Origin, completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()) {
        completion(.failure(Beacon.Error.messageVersionNotSupported(version: "2", blockchainIdentifier: Substrate.identifier)))
    }
}
