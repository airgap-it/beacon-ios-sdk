//
//  OperationV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct OperationV3TezosRequest: Equatable, Codable {
    public let type: String
    public let network: Tezos.Network
    public let operationDetails: [Tezos.Operation]
    public let sourceAddress: String
    
    init(network: Tezos.Network, operationDetails: [Tezos.Operation], sourceAddress: String) {
        self.type = OperationV3TezosRequest.type
        self.network = network
        self.operationDetails = operationDetails
        self.sourceAddress = sourceAddress
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from operationRequest: OperationTezosRequest) {
        self.init(network: operationRequest.network, operationDetails: operationRequest.operationDetails, sourceAddress: operationRequest.sourceAddress)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
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
                                    accountID: accountID,
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
}

// MARK: Extensions

extension OperationV3TezosRequest {
    static let type = "operation_request"
}
