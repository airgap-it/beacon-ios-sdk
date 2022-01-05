//
//  SignPayloadV3TezosResponse.swift
//
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct SignPayloadV3TezosResponse: Equatable, Codable {
    public let type: String
    public let signingType: Tezos.SigningType
    public let signature: String
    
    init(signingType: Tezos.SigningType, signature: String) {
        self.type = SignPayloadV3TezosResponse.type
        self.signingType = signingType
        self.signature = signature
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from signPayloadResponse: SignPayloadTezosResponse) {
        self.init(signingType: signPayloadResponse.signingType, signature: signPayloadResponse.signature)
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
                        .signPayload(
                            .init(
                                id: id,
                                version: version,
                                requestOrigin: origin,
                                blockchainIdentifier: blockchainIdentifier,
                                signingType: signingType,
                                signature: signature
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

extension SignPayloadV3TezosResponse {
    static var type: String { "sign_ayload_response" }
}
