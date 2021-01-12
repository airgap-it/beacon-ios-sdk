//
//  CreateRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix.RoomService {
    
    struct CreateRequest: Codable {
        let visibility: Visibility?
        let roomAliasName: String?
        let name: String?
        let topic: String?
        let invite: [String]?
        let roomVersion: String?
        let preset: Preset?
        let isDirect: Bool?
        
        init(
            visibility: Visibility? = nil,
            roomAliasName: String? = nil,
            name: String? = nil,
            topic: String? = nil,
            invite: [String]? = nil,
            roomVersion: String? = nil,
            preset: Preset? = nil,
            isDirect: Bool? = nil
        ) {
            self.visibility = visibility
            self.roomAliasName = roomAliasName
            self.name = name
            self.topic = topic
            self.invite = invite
            self.roomVersion = roomVersion
            self.preset = preset
            self.isDirect = isDirect
        }
        
        enum CodingKeys: String, CodingKey {
            case visibility
            case roomAliasName = "room_alias_name"
            case name
            case topic
            case invite
            case roomVersion = "room_version"
            case preset
            case isDirect = "is_direct"
        }
        
        enum Visibility: String, Codable {
            case `public`
            case `private`
        }
        
        enum Preset: String, Codable {
            case privateChat = "private_chat"
            case publicChat = "public_chat"
            case trustedPrivateChat = "trusted_private_chat"
        }
    }
}
