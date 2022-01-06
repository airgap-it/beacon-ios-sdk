//
//  BeaconViewModel.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

import BeaconCore
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

class BeaconViewModel: ObservableObject {
    private static let examplePeerID = "2af90f39-824f-b70c-bcc2-c71c1a22e6f8"
    private static let examplePeerName = "Beacon Example Dapp"
    private static let examplePeerPublicKey = "c7eb69b769cb1971ebbc8574993b1b68a8f1e4c72912edb68644c0bccc817a6a"
    private static let examplePeerRelayServer = "beacon-node-1.sky.papers.tech"
    private static let examplePeerVersion = "2"
    
    private static let exampleTezosPublicKey = "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9"
    
    @Published private(set) var beaconRequest: String? = nil
    
    @Published var id: String = BeaconViewModel.examplePeerID
    @Published var name: String = BeaconViewModel.examplePeerName
    @Published var publicKey: String = BeaconViewModel.examplePeerPublicKey
    @Published var relayServer: String = BeaconViewModel.examplePeerRelayServer
    @Published var version: String = BeaconViewModel.examplePeerVersion
    
    private var awaitingRequest: BeaconRequest<Tezos>? = nil
    private var peer: Beacon.P2PPeer {
        Beacon.P2PPeer(
            id: id,
            name: name,
            publicKey: publicKey,
            relayServer: relayServer,
            version: version
        )
    }
    
    private var beaconClient: Beacon.WalletClient?
    
    init() {
        startBeacon()
    }
    
    func sendResponse() {
        guard let request = awaitingRequest else {
            return
        }
        
        beaconRequest = nil
        awaitingRequest = nil
        
        do {
            beaconClient?.respond(with: try response(from: request)) { result in
                switch result {
                case .success(_):
                    print("Sent the response")
                case let .failure(error):
                    print("Failed to send the response, got error: \(error)")
                }
            }
        } catch {
            print("Failed to send the response, got error: \(error)")
        }
    }
    
    func addPeer() {
        self.beaconClient?.add([.p2p(peer)]) { result in
            switch result {
            case .success(_):
                print("Peer added")
            case let .failure(error):
                print("Could not add the peer, got error: \(error)")
            }
        }
    }
    
    func removePeer() {
        beaconClient?.remove([.p2p(peer)]) { result in
            switch result {
            case .success(_):
                print("Successfully removed peers")
            case let .failure(error):
                print("Failed to remove peers, got error: \(error)")
            }
        }
    }
    
    func stop() {
        beaconClient?.disconnect {
            print("disconnected \($0)")
        }
    }
    
    func pause() {
        beaconClient?.pause {
            print("paused \($0)")
        }
    }
    
    func resume() {
        beaconClient?.resume {
            print("resumed \($0)")
        }
    }
    
    func startBeacon() {
        guard beaconClient == nil else {
            listenForRequests()
            return
        }
        
        do {
            Beacon.WalletClient.create(
                with: .init(
                    name: "iOS Beacon SDK Demo",
                    blockchains: [Tezos.factory],
                    connections: [.p2p(.init(client: try Transport.P2P.Matrix.factory()))]
                )
            ) { result in
                switch result {
                case let .success(client):
                    print("Beacon client created")
                    self.beaconClient = client
                    self.listenForRequests()
                case let .failure(error):
                    print("Could not create Beacon client, got error: \(error)")
                }
            }
        } catch {
            print("Could not create Beacon client, got error: \(error)")
        }
    }
    
    private func listenForRequests() {
        beaconClient?.connect { result in
            switch result {
            case .success(_):
                print("Beacon client connected")
                self.beaconClient?.listen(onRequest: self.onBeaconRequest)
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onBeaconRequest(result: Result<BeaconRequest<Tezos>, Beacon.Error>) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try? encoder.encode(request)
            
            DispatchQueue.main.async {
                self.beaconRequest = data.flatMap { String(data: $0, encoding: .utf8) }
                self.awaitingRequest = request
            }
        case let .failure(error):
            print("Error while processing incoming messages: \(error)")
            break
        }
    }
        
    private func response(from request: BeaconRequest<Tezos>) throws -> BeaconResponse<Tezos> {
        switch request {
        case let .permission(content):
            return .permission(
                try PermissionTezosResponse(from: content, publicKey: BeaconViewModel.exampleTezosPublicKey)
            )
        case let .blockchain(blockchain):
            switch blockchain {
            case .signPayload(_):
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .blockchain(.signatureTypeNotSupported)))
            default:
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }
    }
}

extension BeaconRequest: Encodable where T == Tezos {
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .permission(content):
            try content.encode(to: encoder)
        case let .blockchain(blockchain):
            switch blockchain {
            case let .operation(content):
                try content.encode(to: encoder)
            case let .signPayload(content):
                try content.encode(to: encoder)
            case let .broadcast(content):
                try content.encode(to: encoder)
            }
        }
    }
}
