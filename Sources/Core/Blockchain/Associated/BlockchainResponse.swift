//
//  BlockchainResponse.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainResponse {
    associatedtype Permission: PermissionBeaconResponseProtocol & Equatable
    associatedtype Blockchain: BlockchainBeaconResponseProtocol & Equatable
}
