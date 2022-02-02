//
//  SerializedConnectionMessage.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

struct SerializedConnectionMessage: Equatable {
    let origin: Beacon.Origin
    let content: String
}
