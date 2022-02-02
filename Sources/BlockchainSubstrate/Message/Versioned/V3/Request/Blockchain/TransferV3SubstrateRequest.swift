//
//  TransferV3SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct TransferV3SubstrateRequest: BlockchainV3SubstrateRequestProtocol {
    public let type: String
    public let scope: Substrate.Permission.Scope
    public let sourceAddress: String
    public let amount: String
    public let recipient: String
    public let network: Substrate.Network
    public let mode: Mode
    
    init(scope: Substrate.Permission.Scope, sourceAddress: String, amount: String, recipient: String, network: Substrate.Network, mode: Mode) {
        self.type = TransferV3SubstrateRequest.type
        self.scope = scope
        self.sourceAddress = sourceAddress
        self.amount = amount
        self.recipient = recipient
        self.network = network
        self.mode = mode
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainRequest: Substrate.Request.Blockchain) throws {
        switch blockchainRequest {
        case let .transfer(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from transferRequest: TransferSubstrateRequest) {
        self.init(
            scope: transferRequest.scope,
            sourceAddress: transferRequest.sourceAddress,
            amount: transferRequest.amount,
            recipient: transferRequest.recipient,
            network: transferRequest.network,
            mode: Mode(from: transferRequest.mode)
        )
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Substrate.AppMetadata) in appMetadata.senderID == senderID }) { result in
                completion(result.map { appMetadata in
                        .request(
                            .blockchain(
                                .transfer(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        origin: origin,
                                        accountID: accountID,
                                        scope: scope,
                                        sourceAddress: sourceAddress,
                                        amount: amount,
                                        recipient: recipient,
                                        network: network,
                                        mode: mode.toTransferRequestMode()
                                    )
                                )
                            )
                        )
                })
            }
            
        }
    }
    
    // MARK: Types
    
    public enum Mode: String, Codable {
        case broadcast
        case broadcastAndReturn = "broadcast_and_return"
        case `return`
        
        init(from mode: TransferSubstrateRequest.Mode) {
            switch mode {
            case .broadcast:
                self = .broadcast
            case .broadcastAndReturn:
                self = .broadcastAndReturn
            case .return:
                self = .return
            }
        }
        
        func toTransferRequestMode() -> TransferSubstrateRequest.Mode {
            switch self {
            case .broadcast:
                return .broadcast
            case .broadcastAndReturn:
                return .broadcastAndReturn
            case .return:
                return .return
            }
        }
    }
}

// MARK: Extensions

extension TransferV3SubstrateRequest {
    static var type: String { "transfer_request" }
}
