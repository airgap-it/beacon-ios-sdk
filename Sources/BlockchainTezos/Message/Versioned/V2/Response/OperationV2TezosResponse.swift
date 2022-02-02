//
//  OperationV2TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct OperationV2TezosResponse: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let transactionHash: String
    
    init(version: String, id: String, senderID: String, transactionHash: String) {
        type = OperationV2TezosResponse.type
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
                case let .operation(content):
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
    
    public init(from beaconMessage: OperationTezosResponse, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: senderID, transactionHash: beaconMessage.transactionHash)
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        completion(.success(.response(
            .blockchain(
                .operation(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
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

extension OperationV2TezosResponse {
    public static let type = "operation_response"
}
