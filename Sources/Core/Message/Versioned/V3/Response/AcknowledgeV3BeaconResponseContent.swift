//
//  AcknowledgeV3BeaconResponseContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct AcknowledgeV3BeaconResponseContent<BlockchainType: Blockchain>: V3BeaconMessageContentProtocol, Equatable, Codable {
    public let type: String
    
    public init() {
        self.type = AcknowledgeV3BeaconResponseContent.type
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .acknowledge(content):
                self.init(from: content)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: AcknowledgeBeaconResponse) {
        self.init()
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Error>) -> ()
    ) {
        let message = AcknowledgeBeaconResponse(id: id, version: version, requestOrigin: origin)
        completion(.success(.response(.acknowledge(message))))
    }
    
    
}

// MARK: Extensions

extension AcknowledgeV3BeaconResponseContent {
    static var type: String { "acknowledge" }
}
