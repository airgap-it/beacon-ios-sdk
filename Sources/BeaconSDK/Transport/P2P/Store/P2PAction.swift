//
//  P2PAction.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

extension Transport.P2P.Store {
    
    enum Action {
        case onChannelCreated(recipient: String, channelID: String)
        case onChannelEvent(sender: String, channelID: String)
        case onChannelClosed(channelID: String)
        case hardReset
    }
}
