//
//  V3BeaconMessage.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct V3BeaconMessage<BlockchainType: Blockchain>: V3BeaconMessageProtocol {
    public static var version: String { "3" }
    
    public var id: String
    public var version: String
    public var senderID: String
    public var message: Content
    
    public init(id: String, version: String = Self.version, senderID: String, message: Content) {
        self.id = id
        self.version = version
        self.senderID = senderID
        self.message = message
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        let content = try Content.init(from: beaconMessage)
        self.init(id: beaconMessage.id, version: beaconMessage.version, senderID: senderID, message: content)
    }
    
    init(from disconnectMessage: DisconnectBeaconMessage, senderID: String) throws {
        self.init(
            id: disconnectMessage.id,
            version: disconnectMessage.version,
            senderID: disconnectMessage.senderID,
            message: .disconnectMessage(DisconnectV3BeaconMessageContent(from: disconnectMessage))
        )
    }
    
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        message.toBeaconMessage(id: id, version: version, senderID: senderID, origin: origin, destination: destination, completion: completion)
    }
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey {
        case id
        case version
        case senderID = "senderId"
        case message
    }
}

// MARK: Protocol

public protocol V3BeaconMessageProtocol: VersionedBeaconMessageProtocol, Identifiable {
    var id: String { get }
}
