//
//  MatrixState.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.Store {
    
    struct State {
        let userID: String?
        let deviceID: String?
        let accessToken: String?
        
        let transactionCounter: Int
        
        let isPolling: Bool
        let syncToken: String?
        let pollingTimeout: Int64?
        let pollingRetries: Int
        
        let rooms: [String: Matrix.Room]
        
        init(
            userID: String? = nil,
            deviceID: String? = nil,
            accessToken: String? = nil,
            transactionCounter: Int = 0,
            isPolling: Bool = false,
            syncToken: String? = nil,
            pollingTimeout: Int64? = nil,
            pollingRetries: Int = 0,
            rooms: [String: Matrix.Room] = [:]
        ) {
            self.userID = userID
            self.deviceID = deviceID
            self.accessToken = accessToken
            self.transactionCounter = transactionCounter
            self.isPolling = isPolling
            self.syncToken = syncToken
            self.pollingTimeout = pollingTimeout
            self.pollingRetries = pollingRetries
            self.rooms = rooms
        }
        
        init(
            from state: State,
            userID: String?? = nil,
            deviceID: String?? = nil,
            accessToken: String?? = nil,
            transactionCounter: Int? = nil,
            isPolling: Bool? = nil,
            syncToken: String?? = nil,
            pollingTimeout: Int64?? = nil,
            pollingRetries: Int? = nil,
            rooms: [String: Matrix.Room]? = nil
        ) {
            self.init(
                userID: userID ?? state.userID,
                deviceID: deviceID ?? state.deviceID,
                accessToken: accessToken ?? state.accessToken,
                transactionCounter: transactionCounter ?? state.transactionCounter,
                isPolling: isPolling ?? state.isPolling,
                syncToken: syncToken ?? state.syncToken,
                pollingTimeout: pollingTimeout ?? state.pollingTimeout,
                pollingRetries: pollingRetries ?? state.pollingRetries,
                rooms: rooms ?? state.rooms
            )
        }
    }
}
