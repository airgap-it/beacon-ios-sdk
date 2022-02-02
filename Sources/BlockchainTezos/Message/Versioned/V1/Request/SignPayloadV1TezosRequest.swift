//
//  SignPayloadV1TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct SignPayloadV1TezosRequest: V1BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let payload: String
    public let sourceAddress: String
    
    init(version: String, id: String, beaconID: String, payload: String, sourceAddress: String) {
        type = SignPayloadV1TezosRequest.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
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
            beaconID: senderID,
            payload: beaconMessage.payload,
            sourceAddress: beaconMessage.sourceAddress
        )
    }
    
    public func toBeaconMessage(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            try dependencyRegistry().storageManager.findAppMetadata(where: { (appMetadata: Tezos.AppMetadata) in appMetadata.senderID == beaconID }) { result in
                completion(result.map { appMetadata in
                        .request(
                            .blockchain(
                                .signPayload(
                                    .init(
                                        id: id,
                                        version: version,
                                        senderID: beaconID,
                                        appMetadata: appMetadata,
                                        origin: origin,
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
        case beaconID = "beaconId"
        case payload
        case sourceAddress
    }
}

extension SignPayloadV1TezosRequest {
    public static let type = "sign_payload_request"
}
