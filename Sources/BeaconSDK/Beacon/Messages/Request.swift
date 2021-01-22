//
//  Request.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of requests used in the Beacon connection.
    public enum Request: Equatable {
        
        ///
        /// Message requesting the granting of the specified permissions to the sender dApp.
        ///
        /// Expects `Beacon.Response.permission` as a response.
        ///
        /// - permission: The body of the message.
        ///
        case permission(_ permission: Permission)
        
        ///
        /// Message requesting the broadcast of the given Tezos operations.
        ///
        /// The operations may be only partially filled by the dApp and lack certain information.
        /// Expects `Beacon.Response.operation` as a response.
        ///
        /// - operation: The body of the message.
        ///
        case operation(_ operation: Operation)
        
        ///
        /// Message requesting the signature of the given payload.
        ///
        /// Expects `Beacon.Response.signPayload` as a response.
        ///
        /// - signPayload: The body of the message.
        ///
        case signPayload(_ signPayload: SignPayload)
        
        ///
        /// Message requesting the broadcast of the given transaction.
        ///
        /// Expects `Beacon.Response.broadcast` as a response.
        ///
        /// - broadcast: The body of the message.
        ///
        case broadcast(_ broadcast: Broadcast)
        
        // MARK: Attributes
        
        var common: RequestProtocol {
            switch self {
            case let .permission(content):
                return content
            case let .operation(content):
                return content
            case let .signPayload(content):
                return content
            case let .broadcast(content):
                return content
            }
        }
    }
}

// MARK: Protocol

protocol RequestProtocol: MessageProtocol {
    var type: String { get }
    var senderID: String { get }
    var origin: Beacon.Origin { get }
}
