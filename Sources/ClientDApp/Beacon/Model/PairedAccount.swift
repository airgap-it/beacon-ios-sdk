//
//  PairedAccount.swift
//  
//
//  Created by Julia Samol on 24.08.22.
//

import Foundation
import BeaconCore

public struct PairedAccount: Equatable, Codable {
    public let account: Account
    public let peerID: String
    
    public init(account: Account, peerID: String) {
        self.account = account
        self.peerID = peerID
    }
}
