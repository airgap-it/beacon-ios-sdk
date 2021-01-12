//
//  Room.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    struct Room: Codable {
        let status: Status
        let id: String
        let members: [String]
        
        init(status: Status, id: String, members: [String] = []) {
            self.status = status
            self.id = id
            self.members = members
        }
        
        init(from room: Room, status: Status? = nil, id: String? = nil, members: [String]? = nil) {
            self.status = status ?? room.status
            self.id = id ?? room.id
            self.members = members ?? room.members
        }
        
        static func from(sync rooms: EventService.SyncResponse.Rooms) -> [Room] {
            let joined: [Room] = rooms.join?.map { (id, room) in
                let members: [String] = Event.from(syncJoin: room, roomID: id).compactMap { event in
                    switch event {
                    case let .join(content):
                        return content.userID
                    default:
                        return nil
                    }
                }
                
                return Room(status: .joined, id: id, members: members)
            } ?? []
            
            let invited: [Room] = rooms.invite?.map { (id, room) in
                let members: [String] = Event.from(syncInvite: room, roomID: id).compactMap { event in
                    switch event {
                    case let .join(content):
                        return content.userID
                    default:
                        return nil
                    }
                }
                
                return Room(status: .invited, id: id, members: members)
            } ?? []
            
            let left: [Room] = rooms.leave?.map { (id, room) in
                let members: [String] = Event.from(syncLeave: room, roomID: id).compactMap { event in
                    switch event {
                    case let .join(content):
                        return content.userID
                    default:
                        return nil
                    }
                }
                
                return Room(status: .left, id: id, members: members)
            } ?? []
            
            return joined + invited + left
        }
        
        func update(withMembers members: [String]) -> Room {
            Room(from: self, members: (self.members + members).distinct())
        }
        
        enum Status: String, Codable {
            case joined
            case invited
            case left
            case unknown
        }
    }
}
