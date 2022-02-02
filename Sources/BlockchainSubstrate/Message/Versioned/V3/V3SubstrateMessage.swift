//
//  V3SubstrateMessage.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public enum V3SubstrateMessage: BlockchainV3Message {
    public typealias BlockchainType = Substrate
    
    public typealias PermissionRequestContentData = PermissionV3SubstrateRequest
    public typealias BlockchainRequestContentData = BlockchainV3SubstrateRequest
    
    public typealias PermissionResponseContentData = PermissionV3SubstrateResponse
    public typealias BlockchainResponseContentData = BlockchainV3SubstrateResponse
}
