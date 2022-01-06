//
//  OperationV2TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct OperationV2TezosResponse: V2BeaconMessageProtocol, Equatable, Codable {
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
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .blockchain(
                        .operation(
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
        case senderID = "senderId"
        case transactionHash
    }
}

extension OperationV2TezosResponse {
    public static var type: String { "operation_response" }
}
