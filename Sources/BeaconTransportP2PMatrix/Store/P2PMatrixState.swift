//
//  P2PMatrixState.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation
import BeaconCore

extension Transport.P2P.Matrix.Store {
    
    struct State {
        let relayServer: String
        let availableNodes: Int
        let activeChannels: [String: String]
        let inactiveChannels: Set<String>
        
        init(
            relayServer: String,
            availableNodes: Int,
            activeChannels: [String: String] = [:],
            inactiveChannels: Set<String> = []
        ) {
            self.relayServer = relayServer
            self.availableNodes = availableNodes
            self.activeChannels = activeChannels
            self.inactiveChannels = inactiveChannels
        }
        
        init(
            from state: State,
            relayServer: String? = nil,
            availableNodes: Int? = nil,
            activeChannels: [String: String]? = nil,
            inactiveChannels: Set<String>? = nil
        ) {
            self.init(
                relayServer: relayServer ?? state.relayServer,
                availableNodes: availableNodes ?? state.availableNodes,
                activeChannels: activeChannels ?? state.activeChannels,
                inactiveChannels: inactiveChannels ?? state.inactiveChannels
            )
        }
    }
}
