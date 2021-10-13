//
//  PermissionV2TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV2TezosResponse: V2BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    public let threshold: Beacon.Threshold?
    
    public init(
        version: String,
        id: String,
        senderID: String,
        publicKey: String,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope],
        threshold: Beacon.Threshold?
    ) {
        type = PermissionV2TezosResponse.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.publicKey = publicKey
        self.network = network
        self.scopes = scopes
        self.threshold = threshold
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .permission(content):
                self.init(from: content, senderID: senderID)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: PermissionTezosResponse, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            senderID: senderID,
            publicKey: beaconMessage.publicKey,
            network: beaconMessage.network,
            scopes: beaconMessage.scopes,
            threshold: beaconMessage.threshold
        )
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            let tezosMessage: BeaconMessage<Tezos> =
                .response(
                    .permission(
                        .init(
                            id: id,
                            blockchainIdentifier: T.identifier,
                            publicKey: publicKey,
                            network: network,
                            scopes: scopes,
                            threshold: threshold,
                            version: version,
                            requestOrigin: origin
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
        case publicKey
        case network
        case scopes
        case threshold
    }
}

extension PermissionV2TezosResponse {
    public static var type: String { "permission_response" }
}
