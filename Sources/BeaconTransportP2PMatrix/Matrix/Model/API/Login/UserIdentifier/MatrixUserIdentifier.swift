//
//  MatrixUserIdentifier.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension MatrixClient.UserService.LoginRequest {
    
    enum UserIdentifier: Codable {
        case user(User)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(`Type`.self, forKey: .type)
            switch type {
            case .user:
                self = .user(try User(from: decoder))
            default:
                throw Error.notSupported(type.rawValue)
            }
        }
        
        static func user(user: String) -> UserIdentifier {
            .user(User(user: user))
        }
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .user(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        enum `Type`: String, Codable {
            case user = "m.id.user"
            case thirdParty = "m.id.thirdparty"
            case phone = "m.id.phone"
        }
        
        enum Error: Swift.Error {
            case notSupported(String)
        }
    }
}
