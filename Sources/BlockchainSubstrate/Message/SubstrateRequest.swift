//
//  SubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public enum SubstrateRequest: BlockchainRequest {
    public typealias Permission = PermissionSubstrateRequest
    public typealias Blockchain = BlockchainSubstrateRequest
}
