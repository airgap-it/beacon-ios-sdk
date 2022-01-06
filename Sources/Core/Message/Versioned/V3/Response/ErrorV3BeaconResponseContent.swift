//
//  ErrorV3BeaconResponseContent.swift
//  
//
//  Created by Julia Samol on 04.01.22.
//

import Foundation

public struct ErrorV3BeaconResponseContent: V3BeaconMessageContentProtocol, Equatable, Codable {
    public let type: String
    public let errorType: String
    public let description: String?
    public let blockchainIdentifier: String?
    
    public init(errorType: String, description: String? = nil, blockchainIdentifier: String? = nil) {
        self.type = ErrorV3BeaconResponseContent.type
        self.errorType = errorType
        self.description = description
        self.blockchainIdentifier = blockchainIdentifier
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>) throws {
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
    
    public init<T: Blockchain>(from beaconMessage: ErrorBeaconResponse<T>) {
        self.init(
            errorType: beaconMessage.errorType.rawValue,
            description: beaconMessage.description,
            blockchainIdentifier: beaconMessage.errorType.blockchainIdentifier
        )
    }
    
    public func toBeaconMessage<T: Blockchain>(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            guard let errorType = Beacon.ErrorType<T>(rawValue: errorType) else {
                throw Error.unknownErrorType
            }
            
            let message = ErrorBeaconResponse(
                id: id,
                version: version,
                requestOrigin: origin,
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
