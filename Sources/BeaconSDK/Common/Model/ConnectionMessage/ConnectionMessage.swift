//
//  ConnectionMessage.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

enum ConnectionMessage {
    case serialized(SerializedConnectionMessage)
    case beacon(BeaconConnectionMessage)
    
    static func serialized(origin: Beacon.Origin, content: String) -> ConnectionMessage {
        .serialized(SerializedConnectionMessage(origin: origin, content: content))
    }
    
    static func beacon(origin: Beacon.Origin, content: Beacon.Message.Versioned) -> ConnectionMessage {
        .beacon(BeaconConnectionMessage(origin: origin, content: content))
    }
}
