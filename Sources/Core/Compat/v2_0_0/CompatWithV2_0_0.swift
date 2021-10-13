//
//  CompatWithV2_0_0.swift
//  
//
//  Created by Julia Samol on 11.10.21.
//

import Foundation

struct CompatWith2_0_0: VersionedCompat {
    let withVersion: String = "2.0.0"
    
    private let blockchainRegistry: BlockchainRegistryProtocol
    
    init(blockchainRegistry: BlockchainRegistryProtocol) {
        self.blockchainRegistry = blockchainRegistry
    }
    
    private static let chainIdentifier: String = "tezos"
    func blockchain() throws -> ShadowBlockchain {
        guard let blockchain = blockchainRegistry.get(ofType: CompatWith2_0_0.chainIdentifier) else {
            throw Beacon.Error.blockchainNotFound(CompatWith2_0_0.chainIdentifier)
        }
        
        return blockchain
    }
}
