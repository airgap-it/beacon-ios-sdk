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
        amount: String,
        recipient: String,
        mode: TransferSubstrateRequest.Mode,
        on network: Substrate.Network? = nil,
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
            
                let request: BeaconRequest<Substrate> = .blockchain(
                    .transfer(
                        .init(
                            id: requestMetadata.id,
                            version: Substrate.Configuration.messageVersion,
                            senderID: requestMetadata.senderID,
                            origin: requestMetadata.origin,
                            destination: requestMetadata.destination,
                            accountID: account.accountID,
                            sourceAddress: account.address,
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
    }
    
    func requestSubstrateSignPayload(
        payload: Substrate.SignerPayload,
        mode: SignPayloadSubstrateRequest.Mode,
        using connectionKind: Beacon.Connection.Kind = .p2p,
        completion: @escaping (Result<(), Beacon.Error>) -> ()
    ) {
        prepareRequest(for: connectionKind) {
            guard let requestMetadata = $0.get(ifFailure: completion) else { return }
            guard let account = requestMetadata.account else {
                completion(.failure(.noActiveAccount))
                return
            }
            
            let request: BeaconRequest<Substrate> = .blockchain(
                .signPayload(
                    .init(
                        id: requestMetadata.id,
                        version: Substrate.Configuration.messageVersion,
                        senderID: requestMetadata.senderID,
                        origin: requestMetadata.origin,
                        destination: requestMetadata.destination,
                        accountID: account.accountID,
                        address: account.address,
                        payload: payload,
                        mode: mode
                    )
                )
            )
            
            self.request(with: request, completion: completion)
        }
    }
    
    private func getNetwork(forAcountID accountID: String, completion: @escaping (Result<Substrate.Network, Beacon.Error>) -> ()) {
        getPermissions(forAccountIdentifier: accountID) { (result: Result<Substrate.Permission?, Beacon.Error>) -> () in
            guard let permission = result.get(ifFailure: completion) else { return }
            guard let network = permission?.account.network else {
                completion(.failure(.noAccountNetworkFound(accountID)))
                return
            }
            
            completion(.success(network))
        }
    }
}
