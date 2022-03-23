//
//  TransferV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct TransferV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol {
    public typealias BlockchainType = Substrate
    
    public let type: String
    public let transactionHash: String?
    public let signature: String?
    public let payload: String?
    
    init(transactionHash: String? = nil, signature: String? = nil, payload: String? = nil) {
        self.type = TransferV3SubstrateResponse.type
        self.transactionHash = transactionHash
        self.signature = signature
        self.payload = payload
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainResponse: Substrate.Response.Blockchain) throws {
       switch blockchainResponse {
        case let .transfer(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from transferResponse: TransferSubstrateResponse) {
        switch transferResponse {
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
            let transferResponse: TransferSubstrateResponse
            if let transactionHash = transactionHash, signature == nil, payload == nil {
                transferResponse = .submit(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        transactionHash: transactionHash
                    )
                )
            } else if let transactionHash = transactionHash, let signature = signature {
                transferResponse = .submitAndReturn(
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
                transferResponse = .return(
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
                        .transfer(transferResponse)
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

extension TransferV3SubstrateResponse {
    static let type = "transfer_response"
}
