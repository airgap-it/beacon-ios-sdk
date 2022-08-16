//
//  SignPayloadV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct SignPayloadV3TezosRequest: Equatable, Codable {
    public let type: String
    public let signingType: Tezos.SigningType
    public let payload: String
    public let sourceAddress: String
    
    init(signingType: Tezos.SigningType, payload: String, sourceAddress: String) {
        self.type = SignPayloadV3TezosRequest.type
        self.signingType = signingType
        self.payload = payload
        self.sourceAddress = sourceAddress
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from signPayloadRequest: SignPayloadTezosRequest) {
        self.init(signingType: signPayloadRequest.signingType, payload: signPayloadRequest.payload, sourceAddress: signPayloadRequest.sourceAddress)
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
                                .signPayload(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        appMetadata: appMetadata,
                                        origin: origin,
                                        destination: destination,
                                        accountID: accountID,
                                        signingType: signingType,
                                        payload: payload,
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

extension SignPayloadV3TezosRequest {
    static let type = "sign_payload_request"
}
