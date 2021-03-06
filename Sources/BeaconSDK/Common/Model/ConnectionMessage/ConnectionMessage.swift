//
//  ConnectionMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

enum ConnectionMessage: Equatable {
    case serialized(SerializedConnectionMessage)
    case beacon(BeaconConnectionMessage)
    
    static func serialized(originatedFrom origin: Beacon.Origin, withContent content: String) -> ConnectionMessage {
        .serialized(SerializedConnectionMessage(origin: origin, content: content))
    }
    
    static func beacon(originatedFrom origin: Beacon.Origin, withContent content: Beacon.Message.Versioned) -> ConnectionMessage {
        .beacon(BeaconConnectionMessage(origin: origin, content: content))
    }
    
    // MARK: Attributes
    
    var common: ConnectionMessageProtocol {
        switch self {
        case let .serialized(content):
            return content
        case let .beacon(content):
            return content
        }
    }
}

// MARK: Protocol

protocol ConnectionMessageProtocol {
    var origin: Beacon.Origin { get }
}
