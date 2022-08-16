//
//  BeaconProducer+Additions.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

public extension BeaconProducer where Self: Beacon.Client {
    func ownMetadata() throws -> Tezos.AppMetadata {
        .init(senderID: try senderID(), name: app.name, icon: app.icon)
    }
    
    func requestTezosPermission(
        on network: Tezos.Network = .mainnet,
        with scopes: [Tezos.Permission.Scope] = [.operationRequest, .sign],
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                let request: BeaconRequest<Tezos> = .permission(
                    .init(
                        id: requestMetadata.id,
                        version: requestMetadata.version,
                        senderID: requestMetadata.senderID,
                        origin: requestMetadata.origin,
                        destination: requestMetadata.destination,
                        appMetadata: try self.ownMetadata(),
                        network: network,
                        scopes: scopes
                    )
                )
                
                self.request(with: request, completion: completion)
            } catch {
                completion(.failure(.init(error)))
            }
        }
    }
    
    func requestTezosOperation(
        sourceAddress: String,
        operationDetails: [Tezos.Operation] = [],
        on network: Tezos.Network = .mainnet,
        accountID: String? = nil,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                let request: BeaconRequest<Tezos> = .blockchain(
                    .operation(
                        .init(
                            id: requestMetadata.id,
                            version: requestMetadata.version,
                            senderID: requestMetadata.senderID,
                            origin: requestMetadata.origin,
                            destination: requestMetadata.destination,
                            accountID: accountID ?? requestMetadata.accountID,
                            appMetadata: try self.ownMetadata(),
                            network: network,
                            operationDetails: operationDetails,
                            sourceAddress: sourceAddress
                        )
                    )
                )
                
                self.request(with: request, completion: completion)
            } catch {
                completion(.failure(.init(error)))
            }
        }
    }
    
    func requestTezosSignPayload(
        signingType: Tezos.SigningType,
        payload: String,
        sourceAddress: String,
        accountID: String? = nil,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                let request: BeaconRequest<Tezos> = .blockchain(
                    .signPayload(
                        .init(
                            id: requestMetadata.id,
                            version: requestMetadata.version,
                            senderID: requestMetadata.senderID,
                            appMetadata: try self.ownMetadata(),
                            origin: requestMetadata.origin,
                            destination: requestMetadata.destination,
                            accountID: accountID ?? requestMetadata.accountID,
                            signingType: signingType,
                            payload: payload,
                            sourceAddress: sourceAddress
                        )
                    )
                )
                
                self.request(with: request, completion: completion)
            } catch {
                completion(.failure(.init(error)))
            }
        }
    }
    
    func requestTezosBroadcast(
        signedTransaction: String,
        on network: Tezos.Network = .mainnet,
        accountID: String? = nil,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                let request: BeaconRequest<Tezos> = .blockchain(
                    .broadcast(
                        .init(
                            id: requestMetadata.id,
                            version: requestMetadata.version,
                            senderID: requestMetadata.senderID,
                            appMetadata: try self.ownMetadata(),
                            origin: requestMetadata.origin,
                            destination: requestMetadata.destination,
                            accountID: accountID ?? requestMetadata.accountID,
                            network: network,
                            signedTransaction: signedTransaction
                        )
                    )
                )
                
                self.request(with: request, completion: completion)
            } catch {
                completion(.failure(.init(error)))
            }
        }
    }
}
