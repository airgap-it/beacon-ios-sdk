//
//  BlockchainRequest.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainRequest {
    associatedtype Permission: PermissionBeaconRequestProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconRequestProtocol & Equatable
}
