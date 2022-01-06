//
//  ErrorV1BeaconResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
public struct ErrorV1BeaconResponse: V1BeaconMessageProtocol, Equatable, Codable {
    public let type: String
    public let version: String
    public let id: String
    public let beaconID: String
    public let errorType: String
    
    public init(version: String, id: String, beaconID: String, errorType: String) {
        self.type = ErrorV1BeaconResponse.type
        self.version = version
        self.id = id
        self.beaconID = beaconID
        self.errorType = errorType
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init<T: Blockchain>(from beaconMessage: BeaconMessage<T>, senderID: String) throws {
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
    
    public init<T: Blockchain>(from beaconMessage: ErrorBeaconResponse<T>, senderID: String) {
        self.init(version: beaconMessage.version, id: beaconMessage.id, beaconID: senderID, errorType: beaconMessage.errorType.rawValue)
    }
    
    public func toBeaconMessage<T: Blockchain>(
        with origin: Beacon.Origin,
        completion: @escaping (Result<BeaconMessage<T>, Swift.Error>) -> ()
    ) {
        do {
            guard let errorType = Beacon.ErrorType<T>(rawValue: errorType) else {
                throw Error.unknownErrorType
            }
            
            let message = ErrorBeaconResponse<T>(
                id: id,
                version: version,
                requestOrigin: origin,
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
        case beaconID = "beaconId"
        case errorType
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case unknownErrorType
    }
}

// MARK: Extensions

extension ErrorV1BeaconResponse {
    static var type: String { "error" }
}
