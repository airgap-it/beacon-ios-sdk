//
//  PermissionV3SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public struct PermissionV3SubstrateRequest: PermissionV3BeaconRequestContentDataProtocol {
    public let appMetadata: AppMetadata
    public let scopes: [Substrate.Permission.Scope]
    public let networks: [Substrate.Network]
    
    init(appMetadata: AppMetadata, scopes: [Substrate.Permission.Scope], networks: [Substrate.Network]) {
        self.appMetadata = appMetadata
        self.scopes = scopes
        self.networks = networks
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from permissionRequest: Substrate.Request.Permission) throws {
        self.init(appMetadata: .init(from: permissionRequest.appMetadata), scopes: permissionRequest.scopes, networks: permissionRequest.networks)
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Substrate>, Error>) -> ()
    ) {
        completion(.success(.request(
            .permission(
                .init(
                    id: id,
                    version: version,
                    senderID: senderID,
                    origin: origin,
                    appMetadata: appMetadata.toAppMetadata(),
                    scopes: scopes,
                    networks: networks
                )
            )
        )))
    }
    
    // MARK: Types

    public struct AppMetadata: Equatable, Codable {
        public let senderID: String
        public let name: String
        public let icon: String?
        
        init(from appMetadata: Substrate.AppMetadata) {
            self.senderID = appMetadata.senderID
            self.name = appMetadata.name
            self.icon = appMetadata.icon
        }
        
        func toAppMetadata() -> Substrate.AppMetadata {
            Substrate.AppMetadata(senderID: senderID, name: name, icon: icon)
        }
        
        enum CodingKeys: String, CodingKey {
            case senderID = "senderId"
            case name
            case icon
        }
    }
}
