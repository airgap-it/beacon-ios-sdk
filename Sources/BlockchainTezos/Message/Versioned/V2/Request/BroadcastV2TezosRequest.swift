//
//  BroadcastV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct BroadcastV2TezosRequest: V2BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let network: Tezos.Network
    public let signedTransaction: String
    
    init(version: String, id: String, senderID: String, network: Tezos.Network, signedTransaction: String) {
        type = BroadcastV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.network = network
        self.signedTransaction = signedTransaction
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == senderID }) { result in
                let message: Result<BeaconMessage<T>, Swift.Error> = result.map { appMetadata in
                    let tezosMessage: BeaconMessage<Tezos> = .request(
                        .blockchain(
                            .broadcast(
                                .init(
                                    id: id,
                                    version: version,
                                    blockchainIdentifier: T.identifier,
                                    senderID: senderID,
                                    appMetadata: appMetadata,
                                    origin: origin,
                                    accountID: nil,
                                    network: network,
                                    signedTransaction: signedTransaction
                                )
                            )
                        )
                    )
                    
                    guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    return beaconMessage
                }
                
                completion(message)
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
    public static var type: String { "broadcast_request" }
}
