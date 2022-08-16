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
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.response(
            .blockchain(
                .broadcast(
                    .init(
                        id: id,
                        version: version,
                        destination: destination,
                        transactionHash: transactionHash
                    )
                )
            )
        )))
    }
}

// MARK: Extensions

extension BroadcastV3TezosResponse {
    static let type = "broadcast_response"
}
