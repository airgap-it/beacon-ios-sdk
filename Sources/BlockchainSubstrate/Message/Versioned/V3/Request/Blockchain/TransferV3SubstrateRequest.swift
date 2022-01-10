//
//  TransferV3SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct TransferV3SubstrateRequest: BlockchainV3SubstrateRequestProtocol, Equatable, Codable {
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
    
    public init<T: Blockchain>(from blockchainRequest: T.Request.Blockchain, ofType type: T.Type) throws {
        guard let blockchainRequest = blockchainRequest as? BlockchainSubstrateRequest else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountID: String,
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Substrate.AppMetadata) in appMetadata.senderID == senderID }) { result in
                let message: Result<BeaconMessage<T>, Error> = result.map { appMetadata in
                    let substrateMessage: BeaconMessage<Substrate> =
                        .request(
                            .blockchain(
                                .transfer(
                                    .init(
                                        id: id,
                                        version: version,
                                        blockchainIdentifier: blockchainIdentifier,
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
                    
                    guard let beaconMessage = substrateMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    return beaconMessage
                }
                
                completion(message)
            }
            
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: BlockchainV3BeaconRequestContentDataProtocol) -> Bool {
        guard let other = other as? TransferV3SubstrateRequest else {
            return false
        }
        
        return self == other
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
