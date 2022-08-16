//
//  ErrorV3BeaconResponseContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct ErrorV3BeaconResponseContent<BlockchainType: Blockchain>: V3BeaconMessageContentProtocol {
    public let type: String
    public let errorType: String
    public let description: String?
    public let blockchainIdentifier: String?
    
    public init(errorType: String, description: String? = nil) {
        self.type = ErrorV3BeaconResponseContent.type
        self.errorType = errorType
        self.description = description
        self.blockchainIdentifier = BlockchainType.identifier
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<BlockchainType>) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .error(content):
                self.init(from: content)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: ErrorBeaconResponse<BlockchainType>) {
        self.init(
            errorType: beaconMessage.errorType.rawValue,
            description: beaconMessage.description
        )
    }
    
    public func toBeaconMessage(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<BlockchainType>, Swift.Error>) -> ()
    ) {
        do {
            guard let errorType = Beacon.ErrorType<BlockchainType>(rawValue: errorType) else {
                throw Error.unknownErrorType
            }
            
            let message = ErrorBeaconResponse(
                id: id,
                version: version,
                destination: destination,
                errorType: errorType,
                description: description
            )
            completion(.success(.response(.error(message))))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case unknownErrorType
    }
}

// MARK: Extensions

extension ErrorV3BeaconResponseContent {
    static var type: String { "error" }
}
