//
//  V3BeaconMessage.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct V3BeaconMessage: V3BeaconMessageProtocol, Equatable, Codable {
    public var id: String
    public var version: String
    public var senderID: String
    public var message: Content
    
    public init(id: String, version: String, senderID: String, message: Content) {
        self.id = id
        self.version = version
        self.senderID = senderID
        self.message = message
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        let content = try Content.init(from: beaconMessage)
        self.init(id: beaconMessage.id, version: beaconMessage.version, senderID: senderID, message: content)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        message.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, using: storageManager, completion: completion)
    }
}

// MARK: Protocol

public protocol V3BeaconMessageProtocol: VersionedBeaconMessageProtocol {}
