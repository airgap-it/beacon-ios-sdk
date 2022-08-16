//
//  BeaconConnectionMessage.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct BeaconIncomingConnectionMessage<B: Blockchain>: Equatable {
    public let origin: Beacon.Connection.ID
    public let content: VersionedBeaconMessage<B>
}

public struct BeaconOutgoingConnectionMessage<B: Blockchain>: Equatable {
    public let destination: Beacon.Connection.ID
    public let content: VersionedBeaconMessage<B>
}
