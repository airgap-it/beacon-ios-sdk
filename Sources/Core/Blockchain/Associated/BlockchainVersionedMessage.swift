//
//  BlockchainVersionedMessage.swift
//
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainVersionedMessage {
    associatedtype BlockchainType
    
    associatedtype V1: BlockchainV1Message where V1.BlockchainType == BlockchainType
    associatedtype V2: BlockchainV2Message where V2.BlockchainType == BlockchainType
    associatedtype V3: BlockchainV3Message where V3.BlockchainType == BlockchainType
}

public protocol BlockchainV1Message: V1BeaconMessageProtocol {}

public protocol BlockchainV2Message: V2BeaconMessageProtocol {}

public protocol BlockchainV3Message {
    associatedtype BlockchainType
    
    associatedtype PermissionRequestContentData: PermissionV3BeaconRequestContentDataProtocol where PermissionRequestContentData.BlockchainType == BlockchainType
    associatedtype BlockchainRequestContentData: BlockchainV3BeaconRequestContentDataProtocol where BlockchainRequestContentData.BlockchainType == BlockchainType
    
    associatedtype PermissionResponseContentData: PermissionV3BeaconResponseContentDataProtocol where PermissionResponseContentData.BlockchainType == BlockchainType
    associatedtype BlockchainResponseContentData: BlockchainV3BeaconResponseContentDataProtocol where BlockchainResponseContentData.BlockchainType == BlockchainType
}

// MARK: Any

struct AnyBlockchainVersionedMessage: BlockchainVersionedMessage {
    typealias BlockchainType = AnyBlockchain
    
    typealias V1 = AnyBlockchainV1Message
    typealias V2 = AnyBlockchainV2Message
    typealias V3 = AnyBlockchainV3Message
}

struct AnyBlockchainV1Message: BlockchainV1Message {
    typealias BlockchainType = AnyBlockchain
    
    let id: String
    let type: String
    let version: String
    let beaconID: String
    
    private var _type: `Type` { `Type`.allCases.first(where: { type.contains($0.rawValue) }) ?? .unknown }
    
    init(id: String, type: String, version: String, beaconID: String) throws {
        self.id = id
        self.type = type
        self.version = version
        self.beaconID = beaconID
    }
    
    init(from beaconMessage: BeaconMessage<AnyBlockchain>, senderID: String) throws {
        let _type: `Type`
        switch beaconMessage {
        case let .request(request):
            _type = .request
            self.beaconID = request.senderID
        case .response(_):
            _type = .response
            self.beaconID = senderID
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.id = beaconMessage.id
        self.version = beaconMessage.version
        self.type = _type.rawValue
    }
    
    func toBeaconMessage(withOrigin origin: Beacon.Connection.ID, andDestination destination: Beacon.Connection.ID, completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()) {
        runCatching(completion: completion) {
            switch _type {
            case .request:
                completion(.success(.request(.blockchain(.init(id: id, version: version, senderID: beaconID, origin: origin, destination: destination, accountID: nil)))))
            case .response:
                completion(.success(.response(.blockchain(.init(id: id, version: version, destination: destination)))))
            case .unknown:
                throw Beacon.Error.unknownBeaconMessage
            }
        }
    }
    
    enum `Type`: String, CaseIterable {
        case request
        case response
        case unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case version
        case beaconID = "beaconId"
    }
}

struct AnyBlockchainV2Message: BlockchainV2Message {
    typealias BlockchainType = AnyBlockchain
    
    let id: String
    let type: String
    let version: String
    let senderID: String
    
    private var _type: `Type` { `Type`.allCases.first(where: { type.contains($0.rawValue) }) ?? .unknown }
    
    init(id: String, type: String, version: String, senderID: String) throws {
        self.id = id
        self.type = type
        self.version = version
        self.senderID = senderID
    }
    
    init(from beaconMessage: BeaconMessage<AnyBlockchain>, senderID: String) throws {
        let _type: `Type`
        switch beaconMessage {
        case let .request(request):
            _type = .request
            self.senderID = request.senderID
        case .response(_):
            _type = .response
            self.senderID = senderID
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
        
        self.id = beaconMessage.id
        self.version = beaconMessage.version
        self.type = _type.rawValue
    }
    
    func toBeaconMessage(withOrigin origin: Beacon.Connection.ID, andDestination destination: Beacon.Connection.ID, completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()) {
        runCatching(completion: completion) {
            switch _type {
            case .request:
                completion(.success(.request(.blockchain(.init(id: id, version: version, senderID: senderID, origin: origin, destination: destination, accountID: nil)))))
            case .response:
                completion(.success(.response(.blockchain(.init(id: id, version: version, destination: destination)))))
            case .unknown:
                throw Beacon.Error.unknownBeaconMessage
            }
        }
    }
    
    enum `Type`: String, CaseIterable {
        case request
        case response
        case unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case version
        case senderID = "senderId"
    }
}

enum AnyBlockchainV3Message: BlockchainV3Message {
    typealias BlockchainType = AnyBlockchain
    
    struct PermissionRequestContentData: PermissionV3BeaconRequestContentDataProtocol {
        typealias BlockchainType = AnyBlockchain
        
        let appMetadata: AnyAppMetadata
        
        init(from permissionRequest: AnyBlockchainRequest.Permission) throws {
            self.appMetadata = permissionRequest.appMetadata
        }
        
        func toBeaconMessage(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Connection.ID,
            destination: Beacon.Connection.ID,
            completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()
        ) {
            completion(.success(.request(
                .permission(
                    .init(
                        id: id,
                        version: version,
                        senderID: senderID,
                        appMetadata: appMetadata,
                        origin: origin,
                        destination: destination
                    )
                )
            )))
        }
    }
    
    struct BlockchainRequestContentData: BlockchainV3BeaconRequestContentDataProtocol {
        typealias BlockchainType = AnyBlockchain
        
        init(from blockchainRequest: AnyBlockchainRequest.Blockchain) throws {}

        func toBeaconMessage(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Connection.ID,
            destination: Beacon.Connection.ID,
            accountID: String,
            completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()
        ) {
            completion(.success(.request(
                .blockchain(
                    .init(id: id, version: version, senderID: senderID, origin: origin, destination: destination, accountID: accountID)
                )
            )))
        }
    }
    
    struct PermissionResponseContentData: PermissionV3BeaconResponseContentDataProtocol {
        typealias BlockchainType = AnyBlockchain
        
        init(from permissionResponse: AnyBlockchainResponse.Permission) throws {}
        
        func toBeaconMessage(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Connection.ID,
            destination: Beacon.Connection.ID,
            completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()
        ) {
            completion(.success(.response(
                .permission(
                    .init(id: id, version: version, destination: destination)
                )
            )))
        }
    }
    
    struct BlockchainResponseContentData: BlockchainV3BeaconResponseContentDataProtocol {
        typealias BlockchainType = AnyBlockchain
        
        init(from blockchainResponse: AnyBlockchainResponse.Blockchain) throws {}
        
        func toBeaconMessage(
            id: String,
            version: String,
            senderID: String,
            origin: Beacon.Connection.ID,
            destination: Beacon.Connection.ID,
            completion: @escaping (Result<BeaconMessage<AnyBlockchain>, Error>) -> ()
        ) {
            completion(.success(.response(
                .blockchain(
                    .init(id: id, version: version, destination: destination)
                )
            )))
        }
    }
}
