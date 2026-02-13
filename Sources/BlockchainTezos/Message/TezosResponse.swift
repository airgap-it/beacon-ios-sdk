//
//  TezosResponse.swift
//  
//
//  Created by Julia Samol on 29.09.21.
//

import Foundation
import OctezConnectCore

public enum TezosResponse: BlockchainResponse {
    public typealias Permission = PermissionTezosResponse
    public typealias Blockchain = BlockchainTezosResponse
}
