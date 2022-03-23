//
//  VersionedTezosMessage.swift
//  
//
//  Created by Julia Samol on 29.09.21.
//

import Foundation
import BeaconCore

public enum VersionedTezosMessage: BlockchainVersionedMessage {
    public typealias BlockchainType = Tezos
    
    public typealias V1 = V1TezosMessage
    public typealias V2 = V2TezosMessage
    public typealias V3 = V3TezosMessage
}
