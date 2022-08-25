//
//  DisconnectV2BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct DisconnectV2BeaconMessage<BlockchainType: Blockchain>: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    
    public init(version: String = V2BeaconMessage<BlockchainType>.version, id: String, senderID: String) {
        self.type = DisconnectV2BeaconMessage.type
        self.version = version
        self.id = id
        self.senderID = senderID
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage {
        case let .disconnect(content):
            self.init(from: content, senderID: senderID)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: DisconnectBeaconMessage, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: beaconMessage.senderID)
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Swift.Error>) -> ()
    ) {
        let message = DisconnectBeaconMessage(id: id, senderID: senderID, version: version, origin: origin, destination: destination)
        completion(.success(.disconnect(message)))
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
    }
}

// MARK: Extensions

extension DisconnectV2BeaconMessage {
    static var type: String { "disconnect" }
}
