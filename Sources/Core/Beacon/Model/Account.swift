//
//  Account.swift
//  
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation

public struct Account: Equatable, Codable {
    public let accountID: String
    public let address: String
    
    public init(accountID: String, address: String) {
        self.accountID = accountID
        self.address = address
    }
}
