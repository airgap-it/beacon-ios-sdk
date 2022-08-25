//
//  BroadcastV2TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct BroadcastV2TezosResponse: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let transactionHash: String
    
    init(version: String = V2BeaconMessage<Tezos>.version, id: String, senderID: String, transactionHash: String) {
        type = BroadcastV2TezosResponse.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.transactionHash = transactionHash
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .blockchain(blockchain):
                switch blockchain {
                case let .broadcast(content):
                    self.init(from: content, senderID: senderID)
                default:
                    throw Beacon.Error.unknownBeaconMessage
                }
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: BroadcastTezosResponse, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: senderID, transactionHash: beaconMessage.transactionHash)
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        completion(.success(.response(
            .blockchain(
                .broadcast(
                    .init(
                        id: id,
                        version: version,
                        destination: destination,
                        transactionHash: transactionHash
                    )
                )
            )
        )))
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case transactionHash
    }
}

extension BroadcastV2TezosResponse {
    public static let type = "broadcast_response"
}
