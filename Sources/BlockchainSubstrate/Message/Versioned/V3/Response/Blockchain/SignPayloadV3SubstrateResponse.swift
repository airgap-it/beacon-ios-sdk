//
//  SignPayloadV3SubstrateResponse.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SignPayloadV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol {
    public typealias BlockchainType = Substrate
    
    public let type: String
    public let transactionHash: String?
    public let signature: String?
    public let payload: String?
    
    init(transactionHash: String? = nil, signature: String? = nil, payload: String? = nil) {
        self.type = SignPayloadV3SubstrateResponse.type
        self.transactionHash = transactionHash
        self.signature = signature
        self.payload = payload
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainResponse: Substrate.Response.Blockchain) throws {
        switch blockchainResponse {
        case let .signPayload(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from signResponse: SignPayloadSubstrateResponse) {
        switch signResponse {
        case let .submit(content):
            self.init(transactionHash: content.transactionHash)
        case let .submitAndReturn(content):
            self.init(transactionHash: content.transactionHash, signature: content.signature, payload: content.payload)
        case let .return(content):
            self.init(signature: content.signature, payload: content.payload)
        }
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Substrate>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let signResponse: SignPayloadSubstrateResponse
            if let transactionHash = transactionHash, signature == nil, payload == nil {
                signResponse = .submit(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        transactionHash: transactionHash
                    )
                )
            } else if let transactionHash = transactionHash, let signature = signature {
                signResponse = .submitAndReturn(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        transactionHash: transactionHash,
                        signature: signature,
                        payload: payload
                    )
                )
            } else if let signature = signature, transactionHash == nil {
                signResponse = .return(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        signature: signature,
                        payload: payload
                    )
                )
            } else {
                throw Error.invalidMessage
            }
            
            let substrateMessage: BeaconMessage<Substrate> =
                .response(
                    .blockchain(
                        .signPayload(signResponse)
                    )
                )
            
            completion(.success(substrateMessage))
        }
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidMessage
    }
}

// MARK: Extension

extension SignPayloadV3SubstrateResponse {
    static var type: String { "sign_payload_response" }
}
