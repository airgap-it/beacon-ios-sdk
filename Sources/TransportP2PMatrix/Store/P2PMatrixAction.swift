//
//  P2PMatrixAction.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation
import BeaconCore

extension Transport.P2P.Matrix.Store {
    
    enum Action {
        case onChannelCreated(recipient: String, channelID: String)
        case onChannelEvent(sender: String, channelID: String)
        case onChannelClosed(channelID: String)
        
        case hardReset
    }
}
