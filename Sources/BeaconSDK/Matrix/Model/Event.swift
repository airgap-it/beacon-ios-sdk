//
//  Event.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    enum Event {
        case create(Create)
        case invite(Invite)
        case join(Join)
        case textMessage(TextMessage)
        
        var common: EventProtocol {
            switch self {
            case let .create(content):
                return content
            case let .invite(content):
                return content
            case let .join(content):
                return content
            case let .textMessage(content):
                return content
            }
        }
        
        init?(from stateEvent: EventService.StateEvent, node: String, roomID: String) {
            switch stateEvent {
            case let .create(event):
                guard let creator = event.content?.creator else {
                    return nil
                }
                self = .create(Create(node: node, roomID: roomID, creator: creator))
            case let .member(event):
                guard let membership = event.content?.membership else {
                    return nil
                }
                switch membership {
                case .invite:
                    guard let sender = event.sender else {
                        return nil
                    }
                    self = .invite(Invite(node: node, sender: sender, roomID: roomID))
                case .join:
                    guard let sender = event.sender else {
                        return nil
                    }
                    self = .join(Join(node: node, roomID: roomID, userID: sender))
                default:
                    return nil
                }
            case let .message(event):
                guard let sender = event.sender else {
                    return nil
                }
                
                guard let type = event.content?.messageType else {
                    return nil
                }
                
                guard let body = event.content?.body else {
                    return nil
                }
                
                switch type {
                case EventService.StateEvent.Message.Kind.text.rawValue:
                    self = .textMessage(TextMessage(node: node, roomID: roomID, sender: sender, message: body))
                default:
                    return nil
                }
                
            default:
                return nil
            }
        }
        
        static func from(syncRooms rooms: EventService.SyncResponse.Rooms, node: String) -> [Event] {
            let join = rooms.join?.flatMap { (id, room) in from(syncJoin: room, node: node, roomID: id) } ?? []
            let invite = rooms.invite?.flatMap { (id, room) in from(syncInvite: room, node: node, roomID: id) } ?? []
            let leave = rooms.leave?.flatMap { (id, room) in from(syncLeave: room, node: node, roomID: id) } ?? []
            
            return join + invite + leave
        }
        
        static func from(syncJoin join: EventService.SyncResponse.Rooms.Join, node: String, roomID: String) -> [Event] {
            from(syncEvents: (join.state?.events ?? []) + (join.timeline?.events ?? []), node: node, roomID: roomID)
        }
        
        static func from(syncInvite invite: EventService.SyncResponse.Rooms.Invite, node: String, roomID: String) -> [Event] {
            from(syncEvents: invite.state?.events ?? [], node: node, roomID: roomID)
        }
        
        static func from(syncLeave leave: EventService.SyncResponse.Rooms.Leave, node: String, roomID: String) -> [Event] {
            from(syncEvents: (leave.state?.events ?? []) + (leave.timeline?.events ?? []), node: node, roomID: roomID)
        }
        
        static func from(syncEvents events: [EventService.StateEvent], node: String, roomID: String) -> [Event] {
            events.compactMap { Event(from: $0, node: node, roomID: roomID) }
        }
        
        func isOf(kind: Kind) -> Bool {
            switch self {
            case let .create(event):
                return event.kind == kind
            case let .invite(event):
                return event.kind == kind
            case let .join(event):
                return event.kind == kind
            case let .textMessage(event):
                return event.kind == kind
            }
        }
        
        enum Kind {
            case create
            case invite
            case join
            case textMessage
        }
    }
}

// MARK: Protocol

protocol EventProtocol {
    var node: String { get }
}
