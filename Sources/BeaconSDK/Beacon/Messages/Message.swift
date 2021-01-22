//
//  Message.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of messages used in the Beacon communication
    public enum Message: Equatable {
        
        ///
        /// Request message.
        ///
        /// Expects a response sent in reply.
        ///
        /// - request: The body of the message.
        ///
        case request(_ request: Request)
        
        ///
        /// Response message.
        ///
        /// Sent in reply to a request. An attempt to send a response
        /// with no matching pending request will result in an error.
        ///
        /// - response: The body of the message.
        ///
        case response(_ response: Response)
        
        ///
        /// Disconnect message.
        ///
        /// Sent when a peer cancels the connection.
        /// Used internally.
        ///
        /// - disconnect: The body of the message.
        ///
        case disconnect(_ disconnect: Disconnect)
        
        // MARK: Attributes
        
        var common: MessageProtocol {
            switch self {
            case let .request(content):
                return content.common
            case let .response(content):
                return content.common
            case let .disconnect(content):
                return content
            }
        }
        
        var associatedOrigin: Origin {
            switch self {
            case let .request(content):
                return content.common.origin
            case let .response(content):
                return content.common.requestOrigin
            case let.disconnect(content):
                return content.origin
            }
        }
    }
}

// MARK: Protocol

protocol MessageProtocol {
    var id: String { get }
    var version: String { get }
}
