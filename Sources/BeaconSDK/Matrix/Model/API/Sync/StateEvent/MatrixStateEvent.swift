//
//  MatrixStateEvent.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.EventService {
    
    enum StateEvent: Codable {
        case create(Create)
        case member(Member)
        case message(Message)
        case unknown(Unknown)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case `Type`.create.rawValue:
                self = .create(try Create(from: decoder))
            case `Type`.member.rawValue:
                self = .member(try Member(from: decoder))
            case `Type`.message.rawValue:
                self = .message(try Message(from: decoder))
            default:
                self = .unknown(try Unknown(from: decoder))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .create(content):
                try content.encode(to: encoder)
            case let .member(content):
                try content.encode(to: encoder)
            case let .message(content):
                try content.encode(to: encoder)
            case let .unknown(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        enum `Type`: String, Codable {
            case create = "m.room.create"
            case member = "m.room.member"
            case message = "m.room.message"
        }
    }
}
