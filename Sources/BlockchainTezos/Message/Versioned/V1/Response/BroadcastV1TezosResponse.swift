//
//  BroadcastV1TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct BroadcastV1TezosResponse: V1BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let transactionHash: String
    
    init(version: String, id: String, beaconID: String, transactionHash: String) {
        type = BroadcastV1TezosResponse.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
        self.transactionHash = transactionHash
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
        self.init(version: beaconMessage.version, id: beaconMessage.id, beaconID: senderID, transactionHash: beaconMessage.transactionHash)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .blockchain(
                        .broadcast(
                            .init(
                                id: id,
                                version: version,
                                requestOrigin: origin,
                                blockchainIdentifier: T.identifier,
                                transactionHash: transactionHash
                            )
                        )
                    )
                )
            
            guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }

            completion(.success(beaconMessage))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case beaconID = "beaconId"
        case transactionHash
    }
}

extension BroadcastV1TezosResponse {
    public static var type: String { "broadcast_response" }
}
