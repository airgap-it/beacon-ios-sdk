//
//  PermissionV1TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV1TezosResponse: V1BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    public let threshold: Beacon.Threshold?
    
    init(
        version: String,
        id: String,
        beaconID: String,
        publicKey: String,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope],
        threshold: Beacon.Threshold?
    ) {
        type = PermissionV1TezosResponse.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
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
            beaconID: senderID,
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
        case beaconID = "beaconId"
        case publicKey
        case network
        case scopes
        case threshold
    }
}

extension PermissionV1TezosResponse {
    public static var type: String { "permission_response" }
}
