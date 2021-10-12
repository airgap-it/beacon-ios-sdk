//
//  BlockchainVersionedMessage.swift
//
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainVersionedMessage {
    associatedtype V1: V1BeaconMessageProtocol & Equatable & Codable
    associatedtype V2: V2BeaconMessageProtocol & Equatable & Codable
}

// MARK: Any

public struct AnyBlockchainVersionedMessage: BlockchainVersionedMessage {
    public typealias V1 = AnyV1BeaconMessage
    public typealias V2 = AnyV2BeaconMessage
}

public class AnyVersionedBeaconMessage: VersionedBeaconMessageProtocol & Equatable & Codable {
    public let type: String
    public let version: String
    public let id: String
    
    private let beaconMessage: Any?
    
    private init(type: String, version: String, id: String) {
        self.beaconMessage = nil
        
        self.type = type
        self.version = version
        self.id = id
    }
    
    required public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
        self.beaconMessage = beaconMessage
        
        self.type = "any"
        self.version = beaconMessage.version
        self.id = beaconMessage.id
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        using storageManager: StorageManager,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            guard let beaconMessage = beaconMessage as? BeaconMessage<T> else {
                throw Beacon.Error.unknownBeaconMessage
            }
            
            completion(.success(beaconMessage))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Equatable
    
    public static func == (lhs: AnyVersionedBeaconMessage, rhs: AnyVersionedBeaconMessage) -> Bool {
        lhs.type == rhs.type && lhs.version == rhs.version && lhs.id == rhs.id
    }
    
    // MARK: Codable
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let version = try container.decode(String.self, forKey: .version)
        let id = try container.decode(String.self, forKey: .id)
        
        self.init(type: type, version: version, id: id)
    }

    public func encode(to encoder: Encoder) throws {
        if let beaconMessage = beaconMessage as? Encodable {
            try beaconMessage.encode(to: encoder)
        } else {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(version, forKey: .version)
            try container.encode(id, forKey: .id)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
    }
}

public class AnyV1BeaconMessage: AnyVersionedBeaconMessage, V1BeaconMessageProtocol {}
public class AnyV2BeaconMessage: AnyVersionedBeaconMessage, V2BeaconMessageProtocol {}
