//
//  AccountControllerAction.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

extension AccountController.Store {
    
    enum Action {
        case onPeerPaired(peer: Beacon.Peer)
        case onPeerRemoved(peer: Beacon.Peer)
        case resetActivePeer
        
        case onNewActiveAccount(account: PairedAccount)
        case resetActiveAccount
        
        case hardReset
    }
}
