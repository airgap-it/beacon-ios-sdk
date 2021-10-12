//
//  TezosRequest.swift
//  
//
//  Created by Julia Samol on 29.09.21.
//

import Foundation
import BeaconCore

public enum TezosRequest: BlockchainRequest {
    public typealias Permission = PermissionTezosRequest
    public typealias Blockchain = BlockchainTezosRequest
}
