//
//  SignPayloadV2TezosRequest.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct SignPayloadV2TezosRequest: V2BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let signingType: Tezos.SigningType
    public let payload: String
    public let sourceAddress: String
    
    init(version: String, id: String, senderID: String, signingType: Tezos.SigningType, payload: String, sourceAddress: String) {
        type = SignPayloadV2TezosRequest.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.signingType = signingType
        self.payload = payload
        self.sourceAddress = sourceAddress
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        guard let beaconMessage = beaconMessage as? BeaconMessage<Tezos> else {
            throw Beacon.Error.unknownBeaconMessage
        }
        
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

    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        storageManager.findAppMetadata(where: { $0.senderID == senderID }) { result in
            let message: Result<BeaconMessage<T>, Swift.Error> = result.map { appMetadata in
                let tezosMessage: BeaconMessage<Tezos> = .request(
                    .blockchain(
                        .signPayload(
                            .init(
                                type: type,
                                id: id,
                                blockchainIdentifier: T.identifier,
                                senderID: senderID,
                                appMetadata: appMetadata,
                                signingType: .raw,
                                payload: payload,
                                sourceAddress: sourceAddress,
                                origin: origin,
                                version: version
                            )
                        )
                    )
                )
                
                guard let beaconMessage = tezosMessage as? BeaconMessage<T> else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                return beaconMessage
            }
            
            completion(message)
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
    public static var type: String { "sign_payload_request" }
}
