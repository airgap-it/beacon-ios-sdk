//
//  PermissionV1TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV1TezosRequest: V1BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let appMetadata: AppMetadata
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    init(
        version: String,
        id: String,
        beaconID: String,
        appMetadata: AppMetadata,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope]
    ) {
        type = PermissionV1TezosRequest.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
        self.appMetadata = appMetadata
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .permission(content):
                self.init(from: content, senderID: senderID)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: PermissionTezosRequest, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            beaconID: senderID,
            appMetadata: AppMetadata(from: beaconMessage.appMetadata),
            network: beaconMessage.network,
            scopes: beaconMessage.scopes
        )
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        completion(.success(.request(
            .permission(
                .init(
                    id: id,
                    version: version,
                    senderID: beaconID,
                    origin: origin,
                    appMetadata: appMetadata.toAppMetadata(),
                    network: network,
                    scopes: scopes
                )
            )
        )))
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case beaconID = "beaconId"
        case appMetadata
        case network
        case scopes
    }
    
    // MARK: Types
    
    public struct AppMetadata: Equatable, Codable {
        public let beaconID: String
        public let name: String
        public let icon: String?
        
        init(from appMetadata: Tezos.AppMetadata) {
            self.beaconID = appMetadata.senderID
            self.name = appMetadata.name
            self.icon = appMetadata.icon
        }
        
        func toAppMetadata() -> Tezos.AppMetadata {
            Tezos.AppMetadata(senderID: beaconID, name: name, icon: icon)
        }
        
        enum CodingKeys: String, CodingKey {
            case beaconID = "beaconId"
            case name
            case icon
        }
    }
}

extension PermissionV1TezosRequest {
    public static let type = "permission_request"
}
