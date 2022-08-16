//
//  BroadcastV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct BroadcastV3TezosRequest: Equatable, Codable {
    public let type: String
    public let network: Tezos.Network
    public let signedTransaction: String
    
    init(network: Tezos.Network, signedTransaction: String) {
        self.type = BroadcastV3TezosRequest.type
        self.network = network
        self.signedTransaction = signedTransaction
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from broadcastRequest: BroadcastTezosRequest) {
        self.init(network: broadcastRequest.network, signedTransaction: broadcastRequest.signedTransaction)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
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
                                        accountID: accountID,
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
}

// MARK: Extensions

extension BroadcastV3TezosRequest {
    static let type = "broadcast_request"
}
