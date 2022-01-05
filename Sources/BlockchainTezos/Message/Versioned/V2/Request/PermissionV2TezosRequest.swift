//
//  PermissionV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV2TezosRequest: V2BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let appMetadata: AppMetadata
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    init(
        version: String,
        id: String,
        senderID: String,
        appMetadata: AppMetadata,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope]
    ) {
        type = PermissionV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.appMetadata = appMetadata
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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
            senderID: senderID,
            appMetadata: AppMetadata(from: beaconMessage.appMetadata),
            network: beaconMessage.network,
            scopes: beaconMessage.scopes
        )
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .request(
                    .permission(
                        .init(
                            id: id,
                            version: version,
                            blockchainIdentifier: T.identifier,
                            senderID: senderID,
                            appMetadata: appMetadata.toAppMetadata(),
                            origin: origin,
                            network: network,
                            scopes: scopes
                        )
                    )
                )
            
            guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case appMetadata
        case network
        case scopes
    }
    
    // MARK: Types

    public struct AppMetadata: Equatable, Codable {
        public let senderID: String
        public let name: String
        public let icon: String?
        
        init(from appMetadata: Beacon.AppMetadata) {
            self.senderID = appMetadata.senderID
            self.name = appMetadata.name
            self.icon = appMetadata.icon
        }
        
        func toAppMetadata() -> Beacon.AppMetadata {
            Beacon.AppMetadata(senderID: senderID, name: name, icon: icon)
        }
        
        enum CodingKeys: String, CodingKey {
            case senderID = "senderId"
            case name
            case icon
        }
    }
}

extension PermissionV2TezosRequest {
    public static var type: String { "permission_request" }
}
