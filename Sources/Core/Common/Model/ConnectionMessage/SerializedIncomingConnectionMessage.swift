//
//  SerializedConnectionMessage.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

struct SerializedIncomingConnectionMessage: Equatable {
    let origin: Beacon.Connection.ID
    let content: String
}

struct SerializedOutgoingConnectionMessage: Equatable {
    let destination: Beacon.Connection.ID
    let content: String
}
