//
//  PermissionTezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
/// Tezos specific content of the `BeaconResponse.permission` message.
public struct PermissionTezosResponse: PermissionBeaconResponseProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies the request to which the message is responding.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The destination data of the response.
    public let destination: Beacon.Connection.ID
    
    /// The account that is granting the permissions.
    public let account: Tezos.Account
    
    /// The list of granted permissions.
    public let scopes: [Tezos.Permission.Scope]
    
    public let appMetadata: Tezos.AppMetadata?
    
    public let threshold: Tezos.Threshold?
    
    public let notification: Tezos.Notification?
    
    public init(
        from request: Tezos.Request.Permission,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope]? = nil,
        threshold: Tezos.Threshold? = nil,
        notification: Tezos.Notification? = nil
    ) {
        let scopes = scopes ?? request.scopes
        
        self.init(
            id: request.id,
            version: request.version,
            destination: request.origin,
            account: account,
            scopes: scopes,
            appMetadata: nil,
            threshold: threshold,
            notification: notification
        )
    }
    
    public init<T>(
        from request: Tezos.Request.Permission,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope]? = nil,
        consumer : T,
        threshold: Tezos.Threshold? = nil,
        notification: Tezos.Notification? = nil
    )throws where T:BeaconConsumer, T:Beacon.Client {
        let scopes = scopes ?? request.scopes
        let appMetadata: Tezos.AppMetadata? = try consumer.ownMetadata()
        
        self.init(
            id: request.id,
            version: request.version,
            destination: request.origin,
            account: account,
            scopes: scopes,
            appMetadata: appMetadata,
            threshold: threshold,
            notification: notification
        )
    }
    
    public init(
        id: String,
        version: String,
        destination: Beacon.Connection.ID,
        account: Tezos.Account,
        scopes: [Tezos.Permission.Scope],
        appMetadata: Tezos.AppMetadata? = nil,
        threshold: Tezos.Threshold? = nil,
        notification: Tezos.Notification? = nil
    ) {
        self.id = id
        self.version = version
        self.destination = destination
        self.account = account
        self.scopes = scopes
        self.appMetadata = appMetadata
        self.threshold = threshold
        self.notification = notification
    }
}
