//
//  DisconnectV3BeaconMessageContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct DisconnectV3BeaconMessageContent<BlockchainType: Blockchain>: V3BeaconMessageContentProtocol {
    public let type: String
    
    public init() {
        self.type = DisconnectV3BeaconMessageContent.type
    }
 
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>) throws {
        switch beaconMessage {
        case let .disconnect(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: DisconnectBeaconMessage) {
        self.init()
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        let message = DisconnectBeaconMessage(id: id, senderID: senderID, version: version, origin: origin)
        completion(.success(.disconnect(message)))
    }
}

// MARK: Extension

extension DisconnectV3BeaconMessageContent {
    static var type: String { "disconnect" }
}
