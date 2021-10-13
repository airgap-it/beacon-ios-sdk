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
    
    public typealias Permission = AnyPermission
    public typealias ErrorType = MockErrorType
    
    public static var identifier: String = "mock"
    
    public let wallet: BlockchainWallet
    public let creator: MockBlockchainCreator
    public let decoder: BlockchainDecoder
    
    public init(
        wallet: BlockchainWallet = MockBlockchainWallet(),
        creator: MockBlockchainCreator = MockBlockchainCreator(),
        decoder: BlockchainDecoder = MockBlockchainDecoder()
    ) {
        self.wallet = wallet
        self.creator = creator
        self.decoder = decoder
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

public struct MockBlockchainWallet: BlockchainWallet {
    public func address(fromPublicKey publicKey: String) throws -> String {
        publicKey
    }
    
    public init() {}
}

public struct MockBlockchainCreator: BlockchainCreator {
    public typealias ConcreteBlockchain = MockBlockchain
    
    public init() {}
    
    public func extractPermission(
        from request: ConcreteBlockchain.Request.Permission,
        and response: ConcreteBlockchain.Response.Permission,
        completion: @escaping (Result<ConcreteBlockchain.Permission, Error>) -> ()
    ) {
        let permission = AnyPermission(
            accountIdentifier: response.publicKey,
            address: response.publicKey,
            senderID: request.senderID,
            appMetadata: request.appMetadata,
            publicKey: response.publicKey,
            connectedAt: 0,
            threshold: response.threshold
        )
        completion(.success(permission))
    }
}

public struct MockBlockchainDecoder: BlockchainDecoder {
    public init() {}
    
    public func v1(from decoder: Decoder) throws -> V1BeaconMessageProtocol & Codable {
        try MockVersionedMessage.V1(from: decoder)
    }
    
    public func v2(from decoder: Decoder) throws -> V2BeaconMessageProtocol & Codable {
        try MockVersionedMessage.V2(from: decoder)
    }
}

public struct MockRequest: BlockchainRequest {
    public struct Permission: PermissionBeaconRequestProtocol & Equatable & Codable {
        public var appMetadata: Beacon.AppMetadata
        public var blockchainIdentifier: String
        public var senderID: String
        public var origin: Beacon.Origin
        public var id: String
        public var version: String
    }
    
    public struct Blockchain: BlockchainBeaconRequestProtocol & Equatable & Codable {
        public var blockchainIdentifier: String
        public var senderID: String
        public var origin: Beacon.Origin
        public var id: String
        public var version: String
    }
}

public struct MockResponse: BlockchainResponse {
    public struct Permission: PermissionBeaconResponseProtocol & Equatable & Codable {
        public var blockchainIdentifier: String
        public var publicKey: String
        public var threshold: Beacon.Threshold?
        public var requestOrigin: Beacon.Origin
        public var id: String
        public var version: String
    }
    
    public struct Blockchain: BlockchainBeaconResponseProtocol & Equatable & Codable {
        public var blockchainIdentifier: String
        public var requestOrigin: Beacon.Origin
        public var id: String
        public var version: String
    }
}

public struct MockVersionedMessage: BlockchainVersionedMessage {
    public struct V1: V1BeaconMessageProtocol & Equatable & Codable {
        public var type: String
        public var version: String
        public var id: String
        
        public var content: String?
        
        public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
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
        
        public func toBeaconMessage<T: Blockchain>(
            with origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                
                guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                completion(.success(beaconMessage))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public struct V2: V2BeaconMessageProtocol & Equatable & Codable {
        public var type: String
        public var version: String
        public var id: String
        
        public var content: String?
        
        public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
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
        
        public func toBeaconMessage<T: Blockchain>(
            with origin: Beacon.Origin,
            using storageManager: StorageManager,
            completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                
                guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                completion(.success(beaconMessage))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

public struct MockErrorType: ErrorTypeProtocol, Equatable, Codable {
    public let rawValue: String
    
    fileprivate init(_ errorType: ErrorTypeProtocol) {
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

