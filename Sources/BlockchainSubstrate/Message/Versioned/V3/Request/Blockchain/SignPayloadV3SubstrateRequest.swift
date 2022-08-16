//
//  SignPayloadV3SubstrateRequest.swift
//
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct SignPayloadV3SubstrateRequest: BlockchainV3SubstrateRequestProtocol {
    public let type: String
    public let scope: Substrate.Permission.Scope
    public let payload: Substrate.SignerPayload
    public let mode: Mode
    
    init(scope: Substrate.Permission.Scope, payload: Substrate.SignerPayload, mode: Mode) {
        self.type = SignPayloadV3SubstrateRequest.type
        self.scope = scope
        self.payload = payload
        self.mode = mode
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from blockchainRequest: Substrate.Request.Blockchain) throws {
        switch blockchainRequest {
        case let .signPayload(content):
            self.init(from: content)
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from signRequest: SignPayloadSubstrateRequest) {
        self.init(
            scope: signRequest.scope,
            payload: signRequest.payload,
            mode: Mode(from: signRequest.mode)
        )
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
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
                                            .signPayload(
                                                .init(
                                                    id: id,
                                                    version: version,
                                                    senderID: senderID,
                                                    origin: origin,
                                                    destination: destination,
                                                    accountID: accountID,
                                                    address: account.address,
                                                    payload: payload,
                                                    mode: mode.toSignRequestMode()
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
        
        init(from mode: SignPayloadSubstrateRequest.Mode) {
            switch mode {
            case .submit:
                self = .submit
            case .submitAndReturn:
                self = .submitAndReturn
            case .return:
                self = .return
            }
        }
        
        func toSignRequestMode() -> SignPayloadSubstrateRequest.Mode {
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

extension SignPayloadV3SubstrateRequest {
    static var type: String { "sign_payload_request" }
}
