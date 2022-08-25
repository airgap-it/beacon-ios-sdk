//
//  OperationV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct OperationV2TezosRequest: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let network: Tezos.Network
    public let operationDetails: [Tezos.Operation]
    public let sourceAddress: String
    
    init(
        version: String = V2BeaconMessage<Tezos>.version,
        id: String,
        senderID: String,
        network: Tezos.Network,
        operationDetails: [Tezos.Operation],
        sourceAddress: String
    ) {
        type = OperationV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.network = network
        self.operationDetails = operationDetails
        self.sourceAddress = sourceAddress
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
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
    
    public init(from beaconMessage: OperationTezosRequest, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            senderID: senderID,
            network: beaconMessage.network,
            operationDetails: beaconMessage.operationDetails,
            sourceAddress: beaconMessage.sourceAddress
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
                                .operation(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        origin: origin,
                                        destination: destination,
                                        accountID: nil,
                                        appMetadata: appMetadata,
                                        network: network,
                                        operationDetails: operationDetails,
                                        sourceAddress: sourceAddress
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
        case operationDetails
        case sourceAddress
    }
}

extension OperationV2TezosRequest {
    public static let type = "operation_request"
}
