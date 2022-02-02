//
//  VersionedSubstrateMessage.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

public enum VersionedSubstrateMessage: BlockchainVersionedMessage {
    public typealias BlockchainType = Substrate
    
    public typealias V1 = V1SubstrateMessage
    public typealias V2 = V2SubstrateMessage
    public typealias V3 = V3SubstrateMessage
}
