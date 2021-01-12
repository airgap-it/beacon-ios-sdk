//
//  LoginRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.UserService {
    
    enum LoginRequest: Codable {
        case password(Password)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(`Type`.self, forKey: .type)
            switch type {
            case .password:
                self = .password(try Password(from: decoder))
            default:
                throw Error.notSupported(type.rawValue)
            }
        }
        
        static func password(user: String, password: String, deviceID: String) -> LoginRequest {
            .password(
                Password(
                    identifier: UserIdentifier.user(user: user),
                    password: password,
                    deviceID: deviceID
                )
            )
        }
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .password(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        enum `Type`: String, Codable {
            case password = "m.login.password"
            case token = "m.login.token"
        }
        
        enum Error: Swift.Error {
            case notSupported(String)
        }
    }
}
