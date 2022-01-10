//
//  PermissionV3SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3SubstrateResponse: PermissionV3BeaconResponseContentDataProtocol, Equatable, Codable {
    public let appMetadata: Substrate.AppMetadata
    public let scopes: [Substrate.Permission.Scope]
    public let accounts: [Substrate.Account]
    
    init(appMetadata: Substrate.AppMetadata, scopes: [Substrate.Permission.Scope], accounts: [Substrate.Account]) {
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.accounts = accounts
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from permissionResponse: T.Response.Permission, ofType type: T.Type) throws {
        guard let permissionResponse = permissionResponse as? PermissionSubstrateResponse else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.init(appMetadata: permissionResponse.appMetadata, scopes: permissionResponse.scopes, accounts: permissionResponse.accounts)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        blockchainIdentifier: String,
        accountIDs: [String],
        completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let substrateMessage: BeaconMessage<Substrate> =
                .response(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            requestOrigin: origin,
                            blockchainIdentifier: blockchainIdentifier,
                            accountIDs: accountIDs,
                            appMetadata: appMetadata,
                            scopes: scopes,
                            accounts: accounts
                        )
                    )
                )
            
            guard let beaconMessage = substrateMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        }
    }
    
    // MARK: Equatable
    
    public func equals(_ other: PermissionV3BeaconResponseContentDataProtocol) -> Bool {
        guard let other = other as? PermissionV3SubstrateResponse else {
            return false
        }
        
        return self == other
    }
}
