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
    public let decoder: BlockchainDecoder
    
    public init(
        creator: MockBlockchainCreator = MockBlockchainCreator(),
        decoder: BlockchainDecoder = MockBlockchainDecoder()
    ) {
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

public struct MockBlockchainCreator: BlockchainCreator {
    public typealias ConcreteBlockchain = MockBlockchain
    
    public init() {}
    
    public func extractPermission(
        from request: ConcreteBlockchain.Request.Permission,
        and response: ConcreteBlockchain.Response.Permission,
        completion: @escaping (Result<ConcreteBlockchain.Permission, Error>) -> ()
    ) {
        let permission = AnyPermission(
            accountID: response.publicKey,
            senderID: request.senderID,
            connectedAt: 0
        )
        completion(.success(permission))
    }
}

public struct MockBlockchainDecoder: BlockchainDecoder {
    public init() {}
    
    public let v1: BlockchainV1MessageDecoder = V1()
    public let v2: BlockchainV2MessageDecoder = V2()
    public let v3: BlockchainV3MessageDecoder = V3()
    
    public struct V1: BlockchainV1MessageDecoder {
        public func message(from decoder: Decoder) throws -> V1BeaconMessageProtocol & Codable {
            try MockVersionedMessage.V1(from: decoder)
        }
    }
    
    public struct V2: BlockchainV2MessageDecoder {
        public func message(from decoder: Decoder) throws -> V2BeaconMessageProtocol & Codable {
            try MockVersionedMessage.V2(from: decoder)
        }
    }
    
    public struct V3: BlockchainV3MessageDecoder {
        public func permissionRequestData(from decoder: Decoder) throws -> PermissionV3BeaconRequestContentDataProtocol & Codable {
            try MockVersionedMessage.V3.PermissionRequestContentData(from: decoder)
        }
        
        public func blockchainRequestData(from decoder: Decoder) throws -> BlockchainV3BeaconRequestContentDataProtocol & Codable {
            try MockVersionedMessage.V3.BlockchainRequestContentData(from: decoder)
        }
        
        public func permissionResponseData(from decoder: Decoder) throws -> PermissionV3BeaconResponseContentDataProtocol & Codable {
            try MockVersionedMessage.V3.PermissionResponseContentData(from: decoder)
        }
        
        public func blockchainResponseData(from decoder: Decoder) throws -> BlockchainV3BeaconResponseContentDataProtocol & Codable {
            try MockVersionedMessage.V3.BlockchainResponseContentData(from: decoder)
        }
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
        public var blockchainIdentifier: String
        public var publicKey: String
        public var accountID: String
    }
    
    public struct Blockchain: BlockchainBeaconResponseProtocol & Equatable & Codable {
        public var id: String
        public var version: String
        public var requestOrigin: Beacon.Origin
        public var blockchainIdentifier: String
    }
}

public struct MockVersionedMessage: BlockchainVersionedMessage {
    public struct V1: BlockchainV1Message {
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
    
    public struct V2: BlockchainV2Message {
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
    
    public enum V3: BlockchainV3Message {
        public struct PermissionRequestContentData: PermissionV3BeaconRequestContentDataProtocol & Equatable & Codable {
            public var content: String?
            
            public init<T: Blockchain>(from permissionRequest: T.Request.Permission, ofType type: T.Type) throws {
                guard let permissionRequest = permissionRequest as? MockRequest.Permission else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(permissionRequest), encoding: .utf8)
            }
            
            public func toBeaconMessage<T: Blockchain>(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                blockchainIdentifier: String,
                completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                    
                    guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    completion(.success(beaconMessage))
                } catch {
                    completion(.failure(error))
                }
            }
            
            public func equals(_ other: PermissionV3BeaconRequestContentDataProtocol) -> Bool {
                guard let other = other as? PermissionRequestContentData else {
                    return false
                }
                
                return content == other.content
            }
        }
        
        public struct BlockchainRequestContentData: BlockchainV3BeaconRequestContentDataProtocol & Equatable & Codable {
            public var content: String?
    
            public init<T: Blockchain>(from blockchainRequest: T.Request.Blockchain, ofType type: T.Type) throws {
                guard let blockchainRequest = blockchainRequest as? MockRequest.Blockchain else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(blockchainRequest), encoding: .utf8)
            }
            
            public func toBeaconMessage<T: Blockchain>(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                blockchainIdentifier: String,
                accountID: String,
                completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                    
                    guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    completion(.success(beaconMessage))
                } catch {
                    completion(.failure(error))
                }
            }
            
            public func equals(_ other: BlockchainV3BeaconRequestContentDataProtocol) -> Bool {
                guard let other = other as? BlockchainRequestContentData else {
                    return false
                }
                
                return content == other.content
            }
        }
        
        public struct PermissionResponseContentData: PermissionV3BeaconResponseContentDataProtocol & Equatable & Codable {
            public var content: String?
            
            public init<T: Blockchain>(from permissionResponse: T.Response.Permission, ofType type: T.Type) throws {
                guard let permissionResponse = permissionResponse as? MockResponse.Permission else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(permissionResponse), encoding: .utf8)
            }
            
            public func toBeaconMessage<T: Blockchain>(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                blockchainIdentifier: String,
                accountID: String,
                completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                    
                    guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    completion(.success(beaconMessage))
                } catch {
                    completion(.failure(error))
                }
            }
            
            public func equals(_ other: PermissionV3BeaconResponseContentDataProtocol) -> Bool {
                guard let other = other as? PermissionResponseContentData else {
                    return false
                }
                
                return content == other.content
            }
        }
        
        public struct BlockchainResponseContentData: BlockchainV3BeaconResponseContentDataProtocol & Equatable & Codable {
            public var content: String?
            
            public init<T: Blockchain>(from blockchainResponse: T.Response.Blockchain, ofType type: T.Type) throws {
                guard let blockchainResponse = blockchainResponse as? MockResponse.Blockchain else {
                    throw Beacon.Error.unknownBeaconMessage
                }
                
                let encoder = JSONEncoder()
                self.content = String(data: try encoder.encode(blockchainResponse), encoding: .utf8)
            }
            
            public func toBeaconMessage<T: Blockchain>(
                id: String,
                version: String,
                senderID: String,
                origin: Beacon.Origin,
                blockchainIdentifier: String,
                completion: @escaping (Result<BeaconMessage<T>, Error>) -> ()
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
                    
                    guard let beaconMessage = mockMessage as? BeaconMessage<T> else {
                        throw Beacon.Error.unknownBeaconMessage
                    }
                    
                    completion(.success(beaconMessage))
                } catch {
                    completion(.failure(error))
                }
            }
            
            public func equals(_ other: BlockchainV3BeaconResponseContentDataProtocol) -> Bool {
                guard let other = other as? BlockchainResponseContentData else {
                    return false
                }
                
                return content == other.content
            }
        }
    }
}

public struct MockErrorType: ErrorTypeProtocol, Equatable, Codable {
    public let blockchainIdentifier: String? = MockBlockchain.identifier
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

