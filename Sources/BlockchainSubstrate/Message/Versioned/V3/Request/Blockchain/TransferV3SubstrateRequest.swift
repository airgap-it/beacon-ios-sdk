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
    public let amount: String
    public let recipient: String
    public let network: Substrate.Network
    public let mode: Mode
    
    init(scope: Substrate.Permission.Scope, amount: String, recipient: String, network: Substrate.Network, mode: Mode) {
        self.type = TransferV3SubstrateRequest.type
        self.scope = scope
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
                guard result.isSuccess(else: completion) else { return }
                runCatching(completion: completion) {
                    try dependencyRegistry().storageManager.findPermissions(where: { (permission: Substrate.Permission) in permission.accountID == accountID }) { result in
                        guard let permission = result.get(ifFailure: completion) else { return }
                        runCatching(completion: completion) {
                            guard let account = permission?.account else {
                                throw Beacon.Error.accountNotFound(accountID)
                            }
                            
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
                                                    sourceAddress: account.address,
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
            }
            
        }
    }
    
    // MARK: Types
    
    public enum Mode: String, Codable {
        case submit
        case submitAndReturn = "submit_and_return"
        case `return`
        
        init(from mode: TransferSubstrateRequest.Mode) {
            switch mode {
            case .submit:
                self = .submit
            case .submitAndReturn:
                self = .submitAndReturn
            case .return:
                self = .return
            }
        }
        
        func toTransferRequestMode() -> TransferSubstrateRequest.Mode {
            switch self {
            case .submit:
                return .submit
            case .submitAndReturn:
                return .submitAndReturn
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
