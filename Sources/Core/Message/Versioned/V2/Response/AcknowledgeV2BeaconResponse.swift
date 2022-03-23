//
//  AcknowledgeV2BeaconResponse.swift
//
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public struct AcknowledgeV2BeaconResponse<BlockchainType: Blockchain>: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    
    public init(version: String, id: String, senderID: String) {
        self.type = AcknowledgeV2BeaconResponse.type
        self.version = version
        self.id = id
        self.senderID = senderID
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                self.init(from: content, senderID: senderID)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: AcknowledgeBeaconResponse, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: senderID)
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Swift.Error>) -> ()
    ) {
        let message = AcknowledgeBeaconResponse(id: id, version: version, requestOrigin: origin)
        completion(.success(.response(.acknowledge(message))))
    }
}

// MARK: Extensions

extension AcknowledgeV2BeaconResponse {
    static var type: String { "acknowledge" }
}
