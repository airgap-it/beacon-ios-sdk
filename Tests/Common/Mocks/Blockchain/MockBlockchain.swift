//
//  MockBlockchain.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore

public struct MockBlockchain: Blockchain {
    public typealias Creator = MockBlockchainCreator
    
    public typealias Request = MockRequest
    public typealias Response = MockResponse
    public typealias VersionedMessage = MockVersionedMessage
    
    public typealias AppMetadata = AnyAppMetadata
    public typealias Permission = AnyPermission
    public typealias ErrorType = MockErrorType
    
    public static var identifier: String = "mock"
    
    public let creator: MockBlockchainCreator
    public let storageExtension: BlockchainStorageExtension
    
    public init(creator: MockBlockchainCreator = .init(), storageExtension: MockBlockchainStorageExtension = .init(storage: MockExtendedStorage())) {
        self.creator = creator
        self.storageExtension = storageExtension
    }
}

public struct MockBlockchainFactory: BlockchainFactory {
    public static var identifier: String = MockBlockchain.identifier
    
    public init(identifier: String? = nil) {
        if let identifier = identifier {
            MockBlockchain.identifier = identifier
            MockBlockchainFactory.identifier = identifier
        }
    }
    
    public func createShadow(with dependencyRegistry: DependencyRegistry) -> ShadowBlockchain {
        MockBlockchain()
    }
}

public struct MockBlockchainCreator: BlockchainCreator {
    public typealias BlockchainType = MockBlockchain
    
    public init() {}
    
    public func extractPermission(
        from request: BlockchainType.Request.Permission,
        and response: BlockchainType.Response.Permission,
        completion: @escaping (Result<[BlockchainType.Permission], Error>) -> ()
    ) {
        let permissions = response.accountIDs.map {
            AnyPermission(
                accountID: $0,
                senderID: request.senderID,
                connectedAt: 0
            )
        }
        completion(.success(permissions))
    }
}

public struct MockBlockchainStorageExtension: BlockchainStorageExtension {
    private let storage: ExtendedStorage
    
    public init(storage: ExtendedStorage) {
        self.storage = storage
    }
    
    public func removeAppMetadata(where predicate: ((AnyAppMetadata) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removeAppMetadata(ofType: MockBlockchain.AppMetadata.self, where: predicate, completion: completion)
    }
    
    public func removePermissions(where predicate: ((AnyPermission) -> Bool)? = nil, completion: @escaping (Result<(), Error>) -> ()) {
        storage.removePermissions(ofType: MockBlockchain.Permission.self, where: predicate, completion: completion)
    }
}

public struct MockRequest: BlockchainRequest {
    public struct Permission: PermissionBeaconRequestProtocol & Equatable & Codable {
        public typealias AppMetadata = AnyAppMetadata
        
        public var id: String
        public var version: String
        public var blockchainIdentifier: String
        public var senderID: String
        public var appMetadata: AppMetadata
        public var origin: Beacon.Origin
    }
    
    public struct Blockchain: BlockchainBeaconRequestProtocol & Equatable & Codable {
        public var id: String
        public var version: String
        public var blockchainIdentifier: String
        public var senderID: String
        public var origin: Beacon.Origin
        public var accountID: String?
    }
}

public struct MockResponse: BlockchainResponse {
    public struct Permission: PermissionBeaconResponseProtocol & Equatable & Codable {
        public var id: String
        public var version: String
        public var requestOrigin: Beacon.Origin
        public var accountIDs: [String]
    }
    
    public struct Blockchain: BlockchainBeaconResponseProtocol & Equatable & Codable {
        public var id: String
        public var version: String
        public var requestOrigin: Beacon.Origin
    }
}

public struct MockVersionedMessage: BlockchainVersionedMessage {
    public typealias BlockchainType = MockBlockchain
    
    public struct V1: BlockchainV1Message {
        public typealias BlockchainType = MockBlockchain
        
        public var type: String
        public var version: String
        public var id: String
        
        public var content: String?
        
        public init(from beaconMessage: BeaconMessage<MockBlockchain>, senderID: String) throws {
            guard let beaconMessage = beaconMessage as? BeaconMessage<MockBlockchain> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            self.version = beaconMessage.version
            self.id = beaconMessage.id
            
            let encoder = JSONEncoder()
            
            switch beaconMessage {
            case let .request(request):
                switch request {
                case let .permission(content):
                    self.type = "permission_request"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .blockchain(content):
                    self.type = "blockchain_request"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                }
            case let .response(response):
                switch response {
                case let .permission(content):
                    self.type = "permission_response"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .blockchain(content):
                    self.type = "blockchain_response"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .acknowledge(content):
                    self.type = "acknowledge"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .error(content):
                    self.type = "error"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                }
            case let .disconnect(content):
                self.type = "disconnect"
                self.content = String(data: try encoder.encode(content), encoding: .utf8)
            }
        }
        
        public func toBeaconMessage(
            with origin: Beacon.Origin,
            completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
        ) {
            do {
                guard let content = content else {
                    throw Beacon.Error.unknown
                }
                
                let mockMessage: BeaconMessage<MockBlockchain> = try {
                    let decoder = JSONDecoder()
                    
                    switch type {
                    case "permission_request":
                        return .request(.permission(try decoder.decode(MockBlockchain.Request.Permission.self, from: Data(content.utf8))))
                    case "blockchain_request":
                        return .request(.blockchain(try decoder.decode(MockBlockchain.Request.Blockchain.self, from: Data(content.utf8))))
                    case "permission_response":
                        return .response(.permission(try decoder.decode(MockBlockchain.Response.Permission.self, from: Data(content.utf8))))
                    case "blockchain_response":
                        return .response(.blockchain(try decoder.decode(MockBlockchain.Response.Blockchain.self, from: Data(content.utf8))))
                    case "acknowledge":
                        return .response(.acknowledge(try decoder.decode(AcknowledgeBeaconResponse.self, from: Data(content.utf8))))
                    case "error":
                        return .response(.error(try decoder.decode(ErrorBeaconResponse.self, from: Data(content.utf8))))
                    case "disconnect":
                        return .disconnect(try decoder.decode(DisconnectBeaconMessage.self, from: Data(content.utf8)))
                    default:
                        throw Beacon.Error.unknown
                    }
                }()
                
                completion(.success(mockMessage))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public struct V2: BlockchainV2Message {
        public typealias BlockchainType = MockBlockchain
        
        public var type: String
        public var version: String
        public var id: String
        
        public var content: String?
        
        public init(from beaconMessage: BeaconMessage<MockBlockchain>, senderID: String) throws {
            guard let beaconMessage = beaconMessage as? BeaconMessage<MockBlockchain> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            self.version = beaconMessage.version
            self.id = beaconMessage.id
            
            let encoder = JSONEncoder()
            
            switch beaconMessage {
            case let .request(request):
                switch request {
                case let .permission(content):
                    self.type = "permission_request"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .blockchain(content):
                    self.type = "blockchain_request"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                }
            case let .response(response):
                switch response {
                case let .permission(content):
                    self.type = "permission_response"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .blockchain(content):
                    self.type = "blockchain_response"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .acknowledge(content):
                    self.type = "acknowledge"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                case let .error(content):
                    self.type = "error"
                    self.content = String(data: try encoder.encode(content), encoding: .utf8)
                }
            case let .disconnect(content):
                self.type = "disconnect"
                self.content = String(data: try encoder.encode(content), encoding: .utf8)
            }
        }
        
        public func toBeaconMessage(
            with origin: Beacon.Origin,
            completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
        ) {
            do {
                guard let content = content else {
                    throw Beacon.Error.unknown
                }
                
                let mockMessage: BeaconMessage<MockBlockchain> = try {
                    let decoder = JSONDecoder()
                    
                    switch type {
                    case "permission_request":
                        return .request(.permission(try decoder.decode(MockBlockchain.Request.Permission.self, from: Data(content.utf8))))
                    case "blockchain_request":
                        return .request(.blockchain(try decoder.decode(MockBlockchain.Request.Blockchain.self, from: Data(content.utf8))))
                    case "permission_response":
                        return .response(.permission(try decoder.decode(MockBlockchain.Response.Permission.self, from: Data(content.utf8))))
                    case "blockchain_response":
                        return .response(.blockchain(try decoder.decode(MockBlockchain.Response.Blockchain.self, from: Data(content.utf8))))
                    case "acknowledge":
                        return .response(.acknowledge(try decoder.decode(AcknowledgeBeaconResponse.self, from: Data(content.utf8))))
                    case "error":
                        return .response(.error(try decoder.decode(ErrorBeaconResponse.self, from: Data(content.utf8))))
                    case "disconnect":
                        return .disconnect(try decoder.decode(DisconnectBeaconMessage.self, from: Data(content.utf8)))
                    default:
                        throw Beacon.Error.unknown
                    }
                }()
                
                completion(.success(mockMessage))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public enum V3: BlockchainV3Message {
        public typealias BlockchainType = MockBlockchain
        
        public struct PermissionRequestContentData: PermissionV3BeaconRequestContentDataProtocol & Equatable & Codable {
            public typealias BlockchainType = MockBlockchain
            
            public var content: String?
            
            public init(from permissionRequest: MockBlockchain.Request.Permission) throws {
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(permissionRequest), encoding: .utf8)
            }
            
            public func toBeaconMessage(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
            ) {
                do {
                    guard let content = content else {
                        throw Beacon.Error.unknown
                    }
                    
                    let mockMessage: BeaconMessage<MockBlockchain> = try {
                        let decoder = JSONDecoder()
                        let content = try decoder.decode(MockRequest.Permission.self, from: Data(content.utf8))
                        
                        return .request(.permission(content))
                    }()
                    
                    completion(.success(mockMessage))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        public struct BlockchainRequestContentData: BlockchainV3BeaconRequestContentDataProtocol & Equatable & Codable {
            public typealias BlockchainType = MockBlockchain
            
            public var content: String?
    
            public init(from blockchainRequest: MockBlockchain.Request.Blockchain) throws {
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(blockchainRequest), encoding: .utf8)
            }
            
            public func toBeaconMessage(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                accountID: String,
                completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
            ) {
                do {
                    guard let content = content else {
                        throw Beacon.Error.unknown
                    }
                    
                    let mockMessage: BeaconMessage<MockBlockchain> = try {
                        let decoder = JSONDecoder()
                        let content = try decoder.decode(MockRequest.Blockchain.self, from: Data(content.utf8))
                        
                        return .request(.blockchain(content))
                    }()
                
                    completion(.success(mockMessage))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        public struct PermissionResponseContentData: PermissionV3BeaconResponseContentDataProtocol & Equatable & Codable {
            public typealias BlockchainType = MockBlockchain
            
            public var content: String?
            
            public init(from permissionResponse: MockBlockchain.Response.Permission) throws {
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(permissionResponse), encoding: .utf8)
            }
            
            public func toBeaconMessage(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
            ) {
                do {
                    guard let content = content else {
                        throw Beacon.Error.unknown
                    }
                    
                    let mockMessage: BeaconMessage<MockBlockchain> = try {
                        let decoder = JSONDecoder()
                        let content = try decoder.decode(MockResponse.Permission.self, from: Data(content.utf8))
                        
                        return .response(.permission(content))
                    }()
                    
                    completion(.success(mockMessage))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        public struct BlockchainResponseContentData: BlockchainV3BeaconResponseContentDataProtocol & Equatable & Codable {
            public typealias BlockchainType = MockBlockchain
            
            public var content: String?
            
            public init(from blockchainResponse: MockBlockchain.Response.Blockchain) throws {
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(blockchainResponse), encoding: .utf8)
            }
            
            public func toBeaconMessage(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                completion: @escaping (Result<BeaconMessage<MockBlockchain>, Error>) -> ()
            ) {
                do {
                    guard let content = content else {
                        throw Beacon.Error.unknown
                    }
                    
                    let mockMessage: BeaconMessage<MockBlockchain> = try {
                        let decoder = JSONDecoder()
                        let content = try decoder.decode(MockResponse.Blockchain.self, from: Data(content.utf8))
                        
                        return .response(.blockchain(content))
                    }()
                    
                    completion(.success(mockMessage))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}

public struct MockErrorType: ErrorTypeProtocol, Equatable, Codable {
    public let blockchainIdentifier: String? = MockBlockchain.identifier
    public let rawValue: String
    
    fileprivate init<T: ErrorTypeProtocol>(_ errorType: T) {
        self.rawValue = errorType.rawValue
    }
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    // MARK: Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

