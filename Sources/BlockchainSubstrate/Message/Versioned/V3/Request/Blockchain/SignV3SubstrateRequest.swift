//
//  SignV3SubstrateRequest.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SignV3SubstrateRequest: BlockchainV3SubstrateRequestProtocol {
    public let type: String
    public let scope: Substrate.Permission.Scope
    public let network: Substrate.Network
    public let runtimeSpec: Substrate.RuntimeSpec
    public let paylod: String
    public let mode: Mode
    
    init(scope: Substrate.Permission.Scope, network: Substrate.Network, runtimeSpec: Substrate.RuntimeSpec, payload: String, mode: Mode) {
        self.type = SignV3SubstrateRequest.type
        self.scope = scope
        self.network = network
        self.runtimeSpec = runtimeSpec
        self.paylod = payload
        self.mode = mode
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainRequest: Substrate.Request.Blockchain) throws {
        switch blockchainRequest {
        case let .sign(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from signRequest: SignSubstrateRequest) {
        self.init(
            scope: signRequest.scope,
            network: signRequest.network,
            runtimeSpec: signRequest.runtimeSpec,
            payload: signRequest.payload,
            mode: Mode(from: signRequest.mode)
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
                                .sign(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        origin: origin,
                                        accountID: accountID,
                                        scope: scope,
                                        network: network,
                                        runtimeSpec: runtimeSpec,
                                        payload: paylod,
                                        mode: mode.toSignRequestMode()
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
        
        init(from mode: SignSubstrateRequest.Mode) {
            switch mode {
            case .broadcast:
                self = .broadcast
            case .broadcastAndReturn:
                self = .broadcastAndReturn
            case .return:
                self = .return
            }
        }
        
        func toSignRequestMode() -> SignSubstrateRequest.Mode {
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

extension SignV3SubstrateRequest {
    static var type: String { "sign_request" }
}
