//
//  DisconnectV3BeaconMessageContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct DisconnectV3BeaconMessageContent: V3BeaconMessageContentProtocol, Equatable, Codable {
    public let type: String
    
    public init() {
        self.type = DisconnectV3BeaconMessageContent.type
    }
 
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws {
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
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        let message = DisconnectBeaconMessage(id: id, senderID: senderID, version: version, origin: origin)
        completion(.success(.disconnect(message)))
    }
}

// MARK: Extension

extension DisconnectV3BeaconMessageContent {
    static var type: String { "disconnect" }
}
