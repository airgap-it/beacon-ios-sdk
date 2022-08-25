//
//  ErrorV2BeaconResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public struct ErrorV2BeaconResponse<BlockchainType: Blockchain>: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let errorType: String
    
    public init(version: String = V2BeaconMessage<BlockchainType>.version, id: String, senderID: String, errorType: String) {
        self.type = ErrorV2BeaconResponse.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.errorType = errorType
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .error(content):
                self.init(from: content, senderID: senderID)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: ErrorBeaconResponse<BlockchainType>, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, senderID: senderID, errorType: beaconMessage.errorType.rawValue)
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Swift.Error>) -> ()
    ) {
        do {
            guard let errorType = Beacon.ErrorType<BlockchainType>(rawValue: errorType) else {
                throw Error.unknownErrorType
            }
            
            let message = ErrorBeaconResponse<BlockchainType>(
                id: id,
                version: version,
                destination: destination,
                errorType: errorType
            )
            completion(.success(.response(.error(message))))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case errorType
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case unknownErrorType
    }
}

// MARK: Extensions

extension ErrorV2BeaconResponse {
    static var type: String { "error" }
}
