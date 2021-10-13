//
//  TezosResponse.swift
//  
//
//  Created by Julia Samol on 29.09.21.
//

import Foundation
import BeaconCore

public enum TezosResponse: BlockchainResponse {
    public typealias Permission = PermissionTezosResponse
    public typealias Blockchain = BlockchainTezosResponse
}
