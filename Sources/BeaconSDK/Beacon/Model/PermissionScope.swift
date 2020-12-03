//
//  PermissionScope.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    ///Types of permissions supported in Beacon.
    public enum PermissionScope: String, Codable, Equatable {
        case sign
        case operationRequest = "operation_request"
        case threshold
    }
}
