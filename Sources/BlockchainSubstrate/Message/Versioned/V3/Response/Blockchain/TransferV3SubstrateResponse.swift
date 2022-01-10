//
//  TransferV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct TransferV3SubstrateResponse: BlockchainV3SubstrateResponseProtocol, Equatable, Codable {
    public let type: String
    public let transactionHash: String?
    public let payload: String?
    
    init(transactionHash: String? = nil, payload: String? = nil) {
        self.type = TransferV3SubstrateResponse.type
        self.transactionHash = transactionHash
        self.payload = payload
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from blockchainResponse: T.Response.Blockchain, ofType type: T.Type) throws {
        guard let blockchainResponse = blockchainResponse as? BlockchainSubstrateResponse else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        switch blockchainResponse {
        case let .transfer(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from transferResponse: TransferSubstrateResponse) {
        switch transferResponse {
        case let .broadcast(content):
            self.init(transactionHash: content.transactionHash)
        case let .broadcastAndReturn(content):
            self.init(transactionHash: content.transactionHash, payload: content.payload)
        case let .return(content):
            self.init(payload: content.payload)
        }
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let transferResponse: TransferSubstrateResponse
            if let transactionHash = transactionHash, payload == nil {
                transferResponse = .broadcast(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        blockchainIdentifier: blockchainIdentifier,
                        transactionHash: transactionHash
                    )
                )
            } else if let transactionHash = transactionHash, let payload = payload {
                transferResponse = .broadcastAndReturn(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        blockchainIdentifier: blockchainIdentifier,
                        transactionHash: transactionHash,
                        payload: payload
                    )
                )
            } else if let payload = payload, transactionHash == nil {
                transferResponse = .return(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        blockchainIdentifier: blockchainIdentifier,
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
            
            guard let beaconMessage = substrateMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: BlockchainV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? TransferV3SubstrateResponse else {
            return false
        }
        
        return self == other
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidMessage
    }
}

// MARK: Extension

extension TransferV3SubstrateResponse {
    static var type: String { "transfer_response" }
}
