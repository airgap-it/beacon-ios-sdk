//
//  SignPayloadV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct SignPayloadV2TezosRequest: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let signingType: Tezos.SigningType
    public let payload: String
    public let sourceAddress: String
    
    init(version: String = V2BeaconMessage<Tezos>.version, id: String, senderID: String, signingType: Tezos.SigningType, payload: String, sourceAddress: String) {
        type = SignPayloadV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.signingType = signingType
        self.payload = payload
        self.sourceAddress = sourceAddress
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .request(request):
            switch request {
            case let .blockchain(blockchain):
                switch blockchain {
                case let .signPayload(content):
                    self.init(from: content, senderID: senderID)
                default:
                    throw Beacon.Error.unknownBeaconMessage
                }
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: SignPayloadTezosRequest, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            senderID: senderID,
            signingType: beaconMessage.signingType,
            payload: beaconMessage.payload,
            sourceAddress: beaconMessage.sourceAddress
        )
    }

    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == senderID }) { result in
                completion(result.map { appMetadata in
                        .request(
                            .blockchain(
                                .signPayload(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: senderID,
                                        appMetadata: appMetadata,
                                        origin: origin,
                                        destination: destination,
                                        accountID: nil,
                                        signingType: .raw,
                                        payload: payload,
                                        sourceAddress: sourceAddress
                                    )
                                )
                            )
                        )
                })
            }
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case signingType
        case payload
        case sourceAddress
    }
}

extension SignPayloadV2TezosRequest {
    public static let type = "sign_payload_request"
}
