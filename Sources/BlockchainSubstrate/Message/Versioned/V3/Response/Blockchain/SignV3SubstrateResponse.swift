//
//  SignV3SubstrateResponse.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SignV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol {
    public typealias BlockchainType = Substrate
    
    public let type: String
    public let transactionHash: String?
    public let payload: String?
    
    init(transactionHash: String? = nil, payload: String? = nil) {
        self.type = SignV3SubstrateResponse.type
        self.transactionHash = transactionHash
        self.payload = payload
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainResponse: Substrate.Response.Blockchain) throws {
        switch blockchainResponse {
        case let .sign(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from signResponse: SignSubstrateResponse) {
        switch signResponse {
        case let .broadcast(content):
            self.init(transactionHash: content.transactionHash)
        case let .broadcastAndReturn(content):
            self.init(transactionHash: content.transactionHash, payload: content.payload)
        case let .return(content):
            self.init(payload: content.payload)
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
            let signResponse: SignSubstrateResponse
            if let transactionHash = transactionHash, payload == nil {
                signResponse = .broadcast(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        transactionHash: transactionHash
                    )
                )
            } else if let transactionHash = transactionHash, let payload = payload {
                signResponse = .broadcastAndReturn(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        transactionHash: transactionHash,
                        payload: payload
                    )
                )
            } else if let payload = payload, transactionHash == nil {
                signResponse = .return(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        payload: payload
                    )
                )
            } else {
                throw Error.invalidMessage
            }
            
            let substrateMessage: BeaconMessage<Substrate> =
                .response(
                    .blockchain(
                        .sign(signResponse)
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

extension SignV3SubstrateResponse {
    static var type: String { "sign_response" }
}
