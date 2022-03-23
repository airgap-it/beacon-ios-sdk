//
//  SubstrateResponse.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public enum SubstrateResponse: BlockchainResponse {
    public typealias Permission = PermissionSubstrateResponse
    public typealias Blockchain = BlockchainSubstrateResponse
}
