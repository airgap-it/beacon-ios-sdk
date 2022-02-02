//
//  ErrorType.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of errors supported in the Beacon connection.
    public enum ErrorType<B: Blockchain>: ErrorTypeProtocol, Equatable, Codable {
        
        ///
        /// Error specific to a blockchain.
        ///
        ///  Applicable to every `BeaconRequest.blockchain`.
        ///
        case blockchain(B.ErrorType)
        
        ///
        /// Indicates that the request execution has been aborted by the user or the wallet.
        ///
        /// Applicable to every `BeaconRequest`.
        ///
        case aborted
        
        ///
        /// Indicates that an unexpected error occurred.
        ///
        /// Applicable to every `BeaconRequest`.
        ///
        case unknown
        
        public init?(rawValue: String) {
            switch rawValue {
            case ErrorType.abortedRawValue:
                self = .aborted
            case ErrorType.unknownRawValue:
                self = .unknown
            default:
                guard let blockchainErrorType = B.ErrorType(rawValue: rawValue) else {
                    return nil
                }
                self = .blockchain(blockchainErrorType)
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            switch value {
            case ErrorType.abortedRawValue:
                self = .aborted
            case ErrorType.unknownRawValue:
                self = .unknown
            default:
                self = .blockchain(try B.ErrorType(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            try rawValue.encode(to: encoder)
        }
        
        // MARK: Attributes
        
        public var rawValue: String {
            switch self {
            case let .blockchain(content):
                return content.rawValue
            case .aborted:
                return ErrorType.abortedRawValue
            case .unknown:
                return ErrorType.unknownRawValue
            }
        }
    }
}

public protocol ErrorTypeProtocol: Equatable, Codable {
    init?(rawValue: String)
    var rawValue: String { get }
}

// MARK: Any

struct AnyErrorType: ErrorTypeProtocol, Equatable, Codable {
    let rawValue: String
    
    init?(rawValue: String) {
        self.rawValue = rawValue
    }
    
    init<T: ErrorTypeProtocol>(_ errorType: T) {
        self.rawValue = errorType.rawValue
    }
}

// MARK: Extensions

extension Beacon.ErrorType {
    private static var abortedRawValue: String { "ABORTED_ERROR" }
    private static var unknownRawValue: String { "UNKNOWN_ERROR" }
}
