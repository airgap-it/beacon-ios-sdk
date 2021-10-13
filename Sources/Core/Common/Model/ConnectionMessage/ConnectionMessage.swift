//
//  ConnectionMessage.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

enum ConnectionMessage: ConnectionMessageProtocol, Equatable {
    
    case serialized(SerializedConnectionMessage)
    case beacon(BeaconConnectionMessage)
    
    static func serialized(originatedFrom origin: Beacon.Origin, withContent content: String) -> ConnectionMessage {
        .serialized(SerializedConnectionMessage(origin: origin, content: content))
    }
    
    static func beacon(originatedFrom origin: Beacon.Origin, withContent content: VersionedBeaconMessage) -> ConnectionMessage {
        .beacon(BeaconConnectionMessage(origin: origin, content: content))
    }
    
    // MARK: Attributes
    
    public var origin: Beacon.Origin { common.origin }
    
    private var common: ConnectionMessageProtocol {
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
