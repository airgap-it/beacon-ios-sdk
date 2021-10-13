//
//  MatrixAction.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.Store {
    
    enum Action {
        case initialize(userID: String?, deviceID: String?, accessToken: String?)
        case stop(nodes: [String])
        case resume(nodes: [String])
        
        case onSyncSuccess(node: String, syncToken: String?, pollingTimeout: Int64, rooms: [MatrixClient.Room]?, events: [MatrixClient.Event]?)
        case onSyncFailure(node: String)
        
        case onTxnIDCreated
        
        case hardReset
    }
}
