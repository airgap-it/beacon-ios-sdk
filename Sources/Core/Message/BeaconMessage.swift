//
//  BeaconMessage.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
/// Types of messages used in the Beacon communication
public enum BeaconMessage<T: Blockchain>: BeaconMessageProtocol, Equatable {
    
    ///
    /// Request message.
    ///
    /// Expects a response sent in reply.
    ///
    /// - request: The content of the message.
    ///
    case request(_ request: BeaconRequest<T>)
    
    ///
    /// Response message.
    ///
    /// Sent in reply to a request. An attempt to send a response
    /// with no matching pending request will result in an error.
    ///
    /// - response: The content of the message.
    ///
    case response(_ response: BeaconResponse<T>)
    
    ///
    /// Disconnect message.
    ///
    /// Sent when a peer cancels the connection.
    /// Used internally.
    ///
    /// - disconnect: The content of the message.
    ///
    case disconnect(_ disconnect: DisconnectBeaconMessage)
    
    // MARK: Attributes
    
    public var id: String { common.id }
    public var version: String { common.version }
    
    private var common: BeaconMessageProtocol {
        switch self {
        case let .request(content):
            return content
        case let .response(content):
            return content
        case let .disconnect(content):
            return content
        }
    }
    
    var associatedOrigin: Beacon.Origin {
        switch self {
        case let .request(content):
            return content.origin
        case let .response(content):
            return content.requestOrigin
        case let.disconnect(content):
            return content.origin
        }
    }
}

// MARK: Protocol

public protocol BeaconMessageProtocol {
    var id: String { get }
    var version: String { get }
}
