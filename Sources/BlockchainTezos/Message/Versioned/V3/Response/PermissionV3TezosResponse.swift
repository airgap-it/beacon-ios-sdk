//
//  PermissionV3TezosResponse.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosResponse: PermissionV3BeaconResponseContentDataProtocol {
    public let accountID: String
    public let publicKey: String
    public let address: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    public let appMetadata: Tezos.AppMetadata?
    public let threshold: Tezos.Threshold?
    public let notification: Tezos.Notification?
    
    init(accountID: String, publicKey: String, address: String, network: Tezos.Network, scopes: [Tezos.Permission.Scope],
         appMetadata: Tezos.AppMetadata?, threshold: Tezos.Threshold?, notification: Tezos.Notification?) {
        self.accountID = accountID
        self.publicKey = publicKey
        self.address = address
        self.network = network
        self.scopes = scopes
        self.appMetadata = appMetadata
        self.threshold = threshold
        self.notification = notification
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionResponse: Tezos.Response.Permission) throws {
        self.init(
            accountID: permissionResponse.account.accountID,
            publicKey: permissionResponse.account.publicKey,
            address: permissionResponse.account.address,
            network: permissionResponse.account.network,
            scopes: permissionResponse.scopes,
            appMetadata: permissionResponse.appMetadata,
            threshold: permissionResponse.threshold,
            notification: permissionResponse.notification
        )
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.response(
            .permission(
                .init(
                    id: id,
                    version: version,
                    destination: destination,
                    account: .init(accountID: accountID, network: network, publicKey: publicKey, address: address),
                    scopes: scopes,
                    threshold: threshold,
                    notification: notification
                )
            )
        )))
    }
    
    // MARK: Types
    
    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case publicKey
        case address
        case network
        case scopes
        case threshold
        case notification
        case appMetadata
    }
}
