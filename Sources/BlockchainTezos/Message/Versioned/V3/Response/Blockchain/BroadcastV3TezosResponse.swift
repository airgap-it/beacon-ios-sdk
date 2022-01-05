//
//  BroadcastV3TezosResponse.swift
//
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct BroadcastV3TezosResponse: Equatable, Codable {
    public let type: String
    public let transactionHash: String
    
    init(transactionHash: String) {
        self.type = BroadcastV3TezosResponse.type
        self.transactionHash = transactionHash
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from broadcastResponse: BroadcastTezosResponse) {
        self.init(transactionHash: broadcastResponse.transactionHash)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .blockchain(
                        .broadcast(
                            .init(
                                id: id,
                                version: version,
                                requestOrigin: origin,
                                blockchainIdentifier: blockchainIdentifier,
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
}

// MARK: Extensions

extension BroadcastV3TezosResponse {
    static var type: String { "broadcast_response" }
}
