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
                        version: Tezos.Configuration.messageVersion,
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
        operationDetails: [Tezos.Operation] = [],
        on network: Tezos.Network? = nil,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) { requestMetadataResult in
            guard let requestMetadata = requestMetadataResult.get(ifFailure: completion) else { return }
            guard let account = requestMetadata.account else {
                completion(.failure(.noActiveAccount))
                return
            }
            
            self.getNetwork(forAcountID: account.accountID) { networkResult in
                guard let network = network ?? networkResult.get(ifFailure: completion) else { return }
                
                do {
                    let request: BeaconRequest<Tezos> = .blockchain(
                        .operation(
                            .init(
                                id: requestMetadata.id,
                                version: Tezos.Configuration.messageVersion,
                                senderID: requestMetadata.senderID,
                                origin: requestMetadata.origin,
                                destination: requestMetadata.destination,
                                accountID: account.accountID,
                                appMetadata: try self.ownMetadata(),
                                network: network,
                                operationDetails: operationDetails,
                                sourceAddress: account.address
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
    
    func requestTezosSignPayload(
        signingType: Tezos.SigningType,
        payload: String,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            
            do {
                guard let account = requestMetadata.account else {
                    throw Beacon.Error.noActiveAccount
                }
                
                let request: BeaconRequest<Tezos> = .blockchain(
                    .signPayload(
                        .init(
                            id: requestMetadata.id,
                            version: Tezos.Configuration.messageVersion,
                            senderID: requestMetadata.senderID,
                            appMetadata: try self.ownMetadata(),
                            origin: requestMetadata.origin,
                            destination: requestMetadata.destination,
                            accountID: account.accountID,
                            signingType: signingType,
                            payload: payload,
                            sourceAddress: account.address
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
        on network: Tezos.Network? = nil,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            guard let account = requestMetadata.account else {
                completion(.failure(.noActiveAccount))
                return
            }
            
            self.getNetwork(forAcountID: account.accountID) { networkResult in
                guard let network = network ?? networkResult.get(ifFailure: completion) else { return }
            
                do {
                    let request: BeaconRequest<Tezos> = .blockchain(
                        .broadcast(
                            .init(
                                id: requestMetadata.id,
                                version: Tezos.Configuration.messageVersion,
                                senderID: requestMetadata.senderID,
                                appMetadata: try self.ownMetadata(),
                                origin: requestMetadata.origin,
                                destination: requestMetadata.destination,
                                accountID: account.accountID,
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
    
    private func getNetwork(forAcountID accountID: String, completion: @escaping (Result<Tezos.Network, Beacon.Error>) -> ()) {
        getPermissions(forAccountIdentifier: accountID) { (result: Result<Tezos.Permission?, Beacon.Error>) -> () in
            guard let permission = result.get(ifFailure: completion) else { return }
            guard let network = permission?.network else {
                completion(.failure(.noAccountNetworkFound(accountID)))
                return
            }
            
            completion(.success(network))
        }
    }
}
