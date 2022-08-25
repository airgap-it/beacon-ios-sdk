//
//  BroadcastV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct BroadcastV2TezosRequest: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let network: Tezos.Network
    public let signedTransaction: String
    
    init(version: String = V2BeaconMessage<Tezos>.version, id: String, senderID: String, network: Tezos.Network, signedTransaction: String) {
        type = BroadcastV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.network = network
        self.signedTransaction = signedTransaction
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
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
    
    public init(from beaconMessage: BroadcastTezosRequest, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            senderID: senderID,
            network: beaconMessage.network,
            signedTransaction: beaconMessage.signedTransaction
        )
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == senderID }) { result in
                completion(result.map { appMetadata in
                        .request(
                            .blockchain(
                                .broadcast(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        appMetadata: appMetadata,
                                        origin: origin,
                                        destination: destination,
                                        accountID: nil,
                                        network: network,
                                        signedTransaction: signedTransaction
                                    )
                                )
                            )
                        )
                })
            }
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case network
        case signedTransaction
    }
}

extension BroadcastV2TezosRequest {
    public static let type = "broadcast_request"
}
