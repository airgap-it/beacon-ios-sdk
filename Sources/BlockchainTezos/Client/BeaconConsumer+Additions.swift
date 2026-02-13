//
//  BeaconConsumer+Additions.swift
//  
//
//  Created by Julia Samol on 17.08.22.
//

import Foundation
import OctezConnectCore

public extension BeaconConsumer where Self: Beacon.Client {
    func ownMetadata() throws -> Tezos.AppMetadata {
        .init(senderID: try senderID(), name: app.name, icon: app.icon)
    }
   
    func respondToTezosPermission(
        _ request: PermissionTezosRequest,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope]? = nil,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) throws {
        let response: BeaconResponse<Tezos> = .permission(
            try .init(
                from: request,
                account: account,
                scopes: scopes,
                consumer: self
            )
        )
        respond(with: response, completion: completion)
    }
    
    func respondToTezosOperation(
        _ request: OperationTezosRequest,
        transactionHash: String,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        let response: BeaconResponse<Tezos> = .blockchain(
            .operation(
                .init(
                    from: request,
                    transactionHash: transactionHash
                )
            )
        )
        respond(with: response, completion: completion)
    }
    
    func respondToTezosSignPayload(
        _ request: SignPayloadTezosRequest,
        signingType: Tezos.SigningType? = nil,
        signature: String,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        let response: BeaconResponse<Tezos> = .blockchain(
            .signPayload(
                .init(
                    from: request,
                    signingType: signingType,
                    signature: signature
                )
            )
        )
        respond(with: response, completion: completion)
    }
    
    func respondToTezosBroadcast(
        _ request: BroadcastTezosRequest,
        transactionHash: String,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        let response: BeaconResponse<Tezos> = .blockchain(
            .broadcast(
                .init(
                    from: request,
                    transactionHash: transactionHash
                )
            )
        )
        respond(with: response, completion: completion)
    }
}
