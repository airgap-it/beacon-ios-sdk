//
//  P2PMatrixBeaconConfiguration.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

extension Beacon {
    
    public enum P2PMatrixConfiguration {
        public static let matrixAPI: String = "/_matrix/client/r0"
        
        public static let matrixClientAPIBase: String = "/_matrix/client"
        public static let matrixClientAPIVersion: String = "r0"
        public static let matrixClientRoomVersion: String = "5"
        
        public static let matrixMaxSyncRetries: Int = 3
        
        public static let p2pJoinDelaysMs: Int = 200
        public static let p2pMaxJoinRetries: Int = 10
        
        public static let defaultRelayServers: [String] = [
            "beacon-node-1.diamond.papers.tech",
            "beacon-node-1.sky.papers.tech",
            "beacon-node-2.sky.papers.tech",
            "beacon-node-1.hope.papers.tech",
            "beacon-node-1.hope-2.papers.tech",
            "beacon-node-1.hope-3.papers.tech",
            "beacon-node-1.hope-4.papers.tech",
            "beacon-node-1.hope-5.papers.tech"
        ].compactMap { $0 }
    }
}
