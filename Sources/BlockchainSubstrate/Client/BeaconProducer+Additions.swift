//
//  BeaconProducer+Additions.swift
//  
//
//  Created by Julia Samol on 17.08.22.
//

import Foundation
import BeaconCore

public extension BeaconProducer where Self: Beacon.Client {
    func ownMetadata() throws -> Substrate.AppMetadata {
        .init(senderID: try senderID(), name: app.name, icon: app.icon)
    }
    
    func requestSubstratePermission(
        on networks: [Substrate.Network],
        with scopes: [Substrate.Permission.Scope] = [.signPayloadJSON, .signPayloadRaw, .transfer],
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                let request: BeaconRequest<Substrate> = .permission(
                    .init(
                        id: requestMetadata.id,
                        version: Substrate.Configuration.messageVersion,
                        senderID: requestMetadata.senderID,
                        origin: requestMetadata.origin,
                        destination: requestMetadata.destination,
                        appMetadata: try self.ownMetadata(),
                        scopes: scopes,
                        networks: networks
                    )
                )
                
                self.request(with: request, completion: completion)
            } catch {
                completion(.failure(.init(error)))
            }
        }
    }
    
    func requestSubstrateTransfer(
        sourceAddress: String,
        amount: String,
        recipient: String,
        mode: TransferSubstrateRequest.Mode,
        on network: Substrate.Network,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            let request: BeaconRequest<Substrate> = .blockchain(
                .transfer(
                    .init(
                        id: requestMetadata.id,
                        version: Substrate.Configuration.messageVersion,
                        senderID: requestMetadata.senderID,
                        origin: requestMetadata.origin,
                        destination: requestMetadata.destination,
                        accountID: requestMetadata.accountID,
                        sourceAddress: sourceAddress,
                        amount: amount,
                        recipient: recipient,
                        network: network,
                        mode: mode
                    )
                )
            )
            
            self.request(with: request, completion: completion)
        }
    }
    
    func requestSubstrateSignPayload(
        address: String,
        payload: Substrate.SignerPayload,
        mode: SignPayloadSubstrateRequest.Mode,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            let request: BeaconRequest<Substrate> = .blockchain(
                .signPayload(
                    .init(
                        id: requestMetadata.id,
                        version: Substrate.Configuration.messageVersion,
                        senderID: requestMetadata.senderID,
                        origin: requestMetadata.origin,
                        destination: requestMetadata.destination,
                        accountID: requestMetadata.accountID,
                        address: address,
                        payload: payload,
                        mode: mode
                    )
                )
            )
            
            self.request(with: request, completion: completion)
        }
    }
}
