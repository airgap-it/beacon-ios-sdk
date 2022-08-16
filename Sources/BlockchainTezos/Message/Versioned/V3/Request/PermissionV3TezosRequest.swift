//
//  PermissionV3TezosRequest.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3TezosRequest: PermissionV3BeaconRequestContentDataProtocol {
    public let network: Tezos.Network
    public let appMetadata: AppMetadata
    public let scopes: [Tezos.Permission.Scope]
    
    init(network: Tezos.Network, appMetadata: AppMetadata, scopes: [Tezos.Permission.Scope]) {
        self.network = network
        self.appMetadata = appMetadata
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionRequest: Tezos.Request.Permission) throws {
        self.init(network: permissionRequest.network, appMetadata: .init(from: permissionRequest.appMetadata), scopes: permissionRequest.scopes)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Error>) -> ()
    ) {
        completion(.success(.request(
            .permission(
                .init(
                    id: id,
                    version: version,
                    senderID: senderID,
                    origin: origin,
                    destination: destination,
                    appMetadata: appMetadata.toAppMetadata(),
                    network: network,
                    scopes: scopes
                )
            )
        )))
    }
    
    // MARK: Types

    public struct AppMetadata: Equatable, Codable {
        public let senderID: String
        public let name: String
        public let icon: String?
        
        init(from appMetadata: Tezos.AppMetadata) {
            self.senderID = appMetadata.senderID
            self.name = appMetadata.name
            self.icon = appMetadata.icon
        }
        
        func toAppMetadata() -> Tezos.AppMetadata {
            Tezos.AppMetadata(senderID: senderID, name: name, icon: icon)
        }
        
        enum CodingKeys: String, CodingKey {
            case senderID = "senderId"
            case name
            case icon
        }
    }
}
