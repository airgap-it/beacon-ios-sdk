//
//  File.swift
//  
//
//  Created by Isacco on 21.07.23.
//

import Foundation

extension Tezos {
    public struct Notification: Codable, Equatable {
        public let version: Int
        public let apiURL: String
        public let token: String

        
        enum CodingKeys: String, CodingKey {
            case version
            case apiURL = "apiUrl"
            case token
        }
    }
}
