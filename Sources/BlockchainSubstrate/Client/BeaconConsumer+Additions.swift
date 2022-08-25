//
//  BeaconConsumer+Additions.swift
//  
//
//  Created by Julia Samol on 17.08.22.
//

import Foundation
import BeaconCore

public extension BeaconConsumer where Self: Beacon.Client {
   
    func respondToSubstratePermission(
        _ request: PermissionSubstrateRequest,
        accounts: [Substrate.Account],
        scopes: [Substrate.Permission.Scope]? = nil,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        let response: BeaconResponse<Substrate> = .permission(
            .init(
                from: request,
                accounts: accounts,
                scopes: scopes
            )
        )
        respond(with: response, completion: completion)
    }
    
    func respondToSubstrateTransfer(
        _ request: TransferSubstrateRequest,
        transactionHash: String?,
        signature: String?,
        payload: String?,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        do {
            let response: BeaconResponse<Substrate> = .blockchain(
                .transfer(
                    try .init(
                        from: request,
                        transactionHash: transactionHash,
                        signature: signature,
                        payload: payload
                    )
                )
            )
            respond(with: response, completion: completion)
        } catch {
            completion(.failure(Beacon.Error(error)))
        }
    }
    
    func respondToSubstrateSignPayload(
        _ request: SignPayloadSubstrateRequest,
        transactionHash: String?,
        signature: String?,
        payload: String?,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        do {
            let response: BeaconResponse<Substrate> = .blockchain(
                .signPayload(
                    try .init(
                        from: request,
                        transactionHash: transactionHash,
                        signature: signature,
                        payload: payload
                    )
                )
            )
            respond(with: response, completion: completion)
        } catch {
            completion(.failure(Beacon.Error(error)))
        }
    }
}
