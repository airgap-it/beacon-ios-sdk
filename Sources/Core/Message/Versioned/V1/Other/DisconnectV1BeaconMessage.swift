//
//  DisconnectV1BeaconMessage.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public struct DisconnectV1BeaconMessage: V1BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    
    public init(version: String, id: String, beaconID: String) {
        self.type = DisconnectV1BeaconMessage.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        switch beaconMessage {
        case let .disconnect(content):
            self.init(from: content, senderID: senderID)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: DisconnectBeaconMessage, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, beaconID: beaconMessage.senderID)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        let message = DisconnectBeaconMessage(id: id, senderID: beaconID, version: version, origin: origin)
        completion(.success(.disconnect(message)))
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case beaconID = "beaconId"
    }
}

// MARK: Extensions

extension DisconnectV1BeaconMessage {
    static var type: String { "disconnect" }
}
