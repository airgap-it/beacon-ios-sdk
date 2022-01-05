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
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountID: String,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        storageManager.findAppMetadata(where: { $0.senderID == senderID }) { result in
            let message: Result<BeaconMessage<T>, Error> = result.map { appMetadata in
                let tezosMessage: BeaconMessage<Tezos> =
                    .request(
                        .blockchain(
                            .broadcast(
                                .init(
                                    id: id,
                                    version: version,
                                    blockchainIdentifier: blockchainIdentifier,
                                    senderID: senderID,
                                    appMetadata: appMetadata,
                                    origin: origin,
                                    accountID: accountID,
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

// MARK: Extensions

extension BroadcastV3TezosRequest {
    static var type: String { "broadcast_request" }
}
