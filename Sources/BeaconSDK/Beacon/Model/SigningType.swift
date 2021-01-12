//
//  SigningType.swift
//  BeaconSDK
//
//  Created by Julia Samol on 02.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of signatures supported in Beacon.
    public enum SigningType: String, Codable, Equatable {
        case raw
    }
}
