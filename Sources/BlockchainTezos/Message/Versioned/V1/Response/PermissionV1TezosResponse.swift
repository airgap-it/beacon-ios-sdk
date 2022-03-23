//
//  PermissionV1TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV1TezosResponse: V1BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    init(
        version: String,
        id: String,
        beaconID: String,
        publicKey: String,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope]
    ) {
        type = PermissionV1TezosResponse.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
        self.publicKey = publicKey
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
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
            publicKey: beaconMessage.account.publicKey,
            network: beaconMessage.account.network,
            scopes: beaconMessage.scopes
        )
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let address = try dependencyRegistry().extend().tezosWallet.address(fromPublicKey: publicKey)
            let accountID = try dependencyRegistry().identifierCreator.accountID(forAddress: address, onNetworkWithIdentifier: network.identifier)
            completion(.success(.response(
                .permission(
                    .init(
                        id: id,
                        version: version,
                        requestOrigin: origin,
                        account: .init(accountID: accountID, network: network, publicKey: publicKey, address: address),
                        scopes: scopes
                    )
                )
            )))
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
    }
}

extension PermissionV1TezosResponse {
    public static let type = "permission_response"
}
