//
//  OperationV3TezosResponse.swift
//
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct OperationV3TezosResponse: Equatable, Codable {
    public let type: String
    public let transactionHash: String
    
    init(transactionHash: String) {
        self.type = OperationV3TezosResponse.type
        self.transactionHash = transactionHash
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from operationResponse: OperationTezosResponse) {
        self.init(transactionHash: operationResponse.transactionHash)
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
                .operation(
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

extension OperationV3TezosResponse {
    static let type = "operation_response"
}
