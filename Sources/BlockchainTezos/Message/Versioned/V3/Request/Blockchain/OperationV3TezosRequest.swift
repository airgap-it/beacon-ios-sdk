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
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == senderID }) { result in
                let message: Result<BeaconMessage<T>, Error> = result.map { appMetadata in
                    let tezosMessage: BeaconMessage<Tezos> =
                        .request(
                            .blockchain(
                                .operation(
                                    .init(
                                        id: id,
                                        version: version,
                                        blockchainIdentifier: blockchainIdentifier,
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
                    
                    guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    return beaconMessage
                }
                
                completion(message)
            }
        }
    }
}

// MARK: Extensions

extension OperationV3TezosRequest {
    static var type: String { "operation_request" }
}
