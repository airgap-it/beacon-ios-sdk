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
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.response(
            .blockchain(
                .signPayload(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        signingType: signingType,
                        signature: signature
                    )
                )
            )
        )))
    }
}

// MARK: Extensions

extension SignPayloadV3TezosResponse {
    static let type = "sign_ayload_response"
}
