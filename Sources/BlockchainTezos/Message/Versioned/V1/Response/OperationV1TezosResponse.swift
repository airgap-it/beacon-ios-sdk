//
//  OperationV1TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct OperationV1TezosResponse: V1BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let transactionHash: String
    
    init(version: String = V1BeaconMessage<Tezos>.version, id: String, beaconID: String, transactionHash: String) {
        type = OperationV1TezosResponse.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
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
        self.init(version: beaconMessage.version, id: beaconMessage.id, beaconID: senderID, transactionHash: beaconMessage.transactionHash)
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        completion(.success(.response(
            .blockchain(
                .operation(
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
        case beaconID = "beaconId"
        case transactionHash
    }
}

extension OperationV1TezosResponse {
    public static let type = "operation_response"
}
