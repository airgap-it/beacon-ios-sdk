//
//  Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of responses used in the Beacon connection.
    public enum Response: Equatable {
        
        ///
        /// Message responding to `Beacon.Request.permission`.
        ///
        /// - permission: The body of the message.
        ///
        case permission(_ permission: Permission)
        
        ///
        /// Message responding to `Beacon.Request.operation`.
        ///
        /// - operation: The body of the message.
        ///
        case operation(_ operation: Operation)
        
        ///
        /// Message responding to `Beacon.Request.signPayload`.
        ///
        /// - signPayload: The body of the message.
        ///
        case signPayload(_ signPayload: SignPayload)
        
        ///
        /// Message responding to `Beacon.Request.broadcast`.
        ///
        /// - broadcast: The body of the message.
        ///
        case broadcast(_ broadcast: Broadcast)
        
        ///
        /// Message responding to every `Beacon.Request`
        /// informing that the request could not be completed due to an error.
        ///
        /// - error: The body of the message.
        ///
        case error(_ error: Error)
        
        // MARK: Attributes
        
        var common: ResponseProtocol {
            switch self {
            case let .permission(content):
                return content
            case let .operation(content):
                return content
            case let .signPayload(content):
                return content
            case let .broadcast(content):
                return content
            case let .error(content):
                return content
            }
        }
    }
}

// MARK: Protocol

protocol ResponseProtocol: MessageProtocol {}
