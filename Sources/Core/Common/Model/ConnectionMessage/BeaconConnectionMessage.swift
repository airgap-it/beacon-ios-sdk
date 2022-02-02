//
//  BeaconConnectionMessage.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public struct BeaconConnectionMessage<B: Blockchain>: Equatable {
    public let origin: Beacon.Origin
    public let content: VersionedBeaconMessage<B>
}
