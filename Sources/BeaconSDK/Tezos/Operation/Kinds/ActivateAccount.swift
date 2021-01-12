//
//  ActivateAccount.swift
//  TezosKit
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct ActivateAccount: Codable, Equatable {
        public let kind: Kind
        public let pkh: String
        public let secret: String
        
        public init(pkh: String, secret: String) {
            kind = .activateAccount
            self.pkh = pkh
            self.secret = secret
        }
    }
}
