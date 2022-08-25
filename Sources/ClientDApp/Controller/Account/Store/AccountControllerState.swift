//
//  AccountControllerState.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore

extension AccountController.Store {
    
    struct State {
        let activeAccount: PairedAccount?
        let activePeer: Beacon.Peer?
        
        init(activeAccount: PairedAccount? = nil, activePeer: Beacon.Peer? = nil) {
            self.activeAccount = activeAccount
            self.activePeer = activePeer
        }
        
        init(from state: State, activeAccount: PairedAccount? = nil, activePeer: Beacon.Peer? = nil) {
            self.init(
                activeAccount: activeAccount ?? state.activeAccount,
                activePeer: activePeer ?? state.activePeer
            )
        }
    }
}
