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
                        .operation(
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

extension OperationV3TezosResponse {
    static var type: String { "operation_response" }
}
