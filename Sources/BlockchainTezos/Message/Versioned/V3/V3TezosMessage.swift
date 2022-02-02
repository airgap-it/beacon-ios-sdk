//
//  V3TezosMessage.swift
//  
//
//  Created by Julia Samol on 05.01.22.
//

import Foundation
import BeaconCore

public enum V3TezosMessage: BlockchainV3Message {
    public typealias BlockchainType = Tezos
    
    public typealias PermissionRequestContentData = PermissionV3TezosRequest
    public typealias BlockchainRequestContentData = BlockchainV3TezosRequest
    
    public typealias PermissionResponseContentData = PermissionV3TezosResponse
    public typealias BlockchainResponseContentData = BlockchainV3TezosResponse
}
