//
//  SignV3SubstrateRequest.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SignV3SubstrateRequest: BlockchainV3SubstrateRequestProtocol, Equatable, Codable {
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
    
    public init<T: Blockchain>(from blockchainRequest: T.Request.Blockchain, ofType type: T.Type) throws {
        guard let blockchainRequest = blockchainRequest as? BlockchainSubstrateRequest else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
                                .sign(
                                    .init(
                                        id: id,
                                        version: version,
                                        blockchainIdentifier: blockchainIdentifier,
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
        guard let other = other as? SignV3SubstrateRequest else {
            return false
        }
        
        return self == other
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
