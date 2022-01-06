//
//  OperationV1TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct OperationV1TezosRequest: V1BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let network: Tezos.Network
    public let operationDetails: [Tezos.Operation]
    public let sourceAddress: String
    
    init(
        version: String,
        id: String,
        beaconID: String,
        network: Tezos.Network,
        operationDetails: [Tezos.Operation],
        sourceAddress: String
    ) {
        type = OperationV1TezosRequest.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
        self.network = network
        self.operationDetails = operationDetails
        self.sourceAddress = sourceAddress
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
            beaconID: senderID,
            network: beaconMessage.network,
            operationDetails: beaconMessage.operationDetails,
            sourceAddress: beaconMessage.sourceAddress
        )
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == beaconID }) { result in
            let message: Result<BeaconMessage<T>, Swift.Error> = result.map { appMetadata in
                let tezosMessage: BeaconMessage<Tezos> = .request(
                    .blockchain(
                        .operation(
                            .init(
                                id: id,
                                version: version,
                                blockchainIdentifier: T.identifier,
                                senderID: beaconID,
                                appMetadata: appMetadata,
                                origin: origin,
                                accountID: nil,
                                network: network,
                                operationDetails: operationDetails,
                                sourceAddress: sourceAddress
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
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case beaconID = "beaconId"
        case network
        case operationDetails
        case sourceAddress
    }
}

extension OperationV1TezosRequest {
    public static var type: String { "operation_request" }
}
