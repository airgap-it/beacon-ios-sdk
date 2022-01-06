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
        storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == senderID }) { result in
            let message: Result<BeaconMessage<T>, Error> = result.map { appMetadata in
                let tezosMessage: BeaconMessage<Tezos> =
                    .request(
                        .blockchain(
                            .signPayload(
                                .init(
                                    id: id,
                                    version: version,
                                    blockchainIdentifier: blockchainIdentifier,
                                    senderID: senderID,
                                    appMetadata: appMetadata,
                                    origin: origin,
                                    accountID: accountID,
                                    signingType: signingType,
                                    payload: payload,
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

// MARK: Extensions

extension SignPayloadV3TezosRequest {
    static var type: String { "sign_payload_request" }
}
