//
//  ErrorType.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

extension Substrate {
    
    /// Types of Substrate errors supported in Beacon.
    public struct ErrorType: ErrorTypeProtocol, Equatable, Codable {
        
        // TODO: define cases
        
        public init?(rawValue: String) {
            return nil
        }
        
        public var rawValue: String { "" }
        
        public var blockchainIdentifier: String? { Substrate.identifier }
    }
}
