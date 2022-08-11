//
//  WalletViewModel.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

import BeaconCore
import BeaconBlockchainSubstrate
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

class WalletViewModel: ObservableObject {
    private static let examplePairingRequest = "3NDKTWt2x3L5cYYtM2jL8YcpgmPR8EQbNNa4yoffDb1qXTMTydqVPkgHRjcWBcvmxTLAQ4D8JrvkrYvfnKjwvXTeojrzHN4KvnX6kYzgwtoDruE8hiwJynSDcFihkWaaUZKkTrkDYqz24c1Si6xWtkUa5SGuqDq2sE6TQhHita59BVWhh4zqyST8DKTnYEdSy93B6ei29cWcgmQamYPBSXLqn6toadS6yZUUH9mV2w8dhwvgXC9bDK4oGDxzT7zTofrP8bRwXPUUc3NGRc2MGhahTS5XsaFWqjxbKBX8JK7jSUHR9fJfxHoVQtav66BtVMtVtEt"
    
    private static func exampleTezosAccount(network: Tezos.Network) throws -> Tezos.Account {
        try Tezos.Account(
            publicKey: "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9",
            address: "tz1Mg6uXUhJzuCh4dH2mdBdYBuaiVZCCZsak",
            network: network
        )
    }

    private static func exampleSubstrateAccount(network: Substrate.Network) throws -> Substrate.Account {
        try Substrate.Account(
            publicKey: "628f3940a6210a2135ba355f7ff9f8e9fbbfd04f8571e99e1df75554d4bcd24f",
            address: "5EHw6XmdpoaaJiPMXFKr1CcHcXPVYZemc9NoKHhEoguavzJN",
            network: network
        )
    }
    
    @Published private(set) var started: Bool = false
    @Published private(set) var beaconRequest: String? = nil
    @Published var pairingRequest: String = WalletViewModel.examplePairingRequest
    
    private var awaitingTezosRequest: BeaconRequest<Tezos>? = nil
    private var awaitingSubstrateRequest: BeaconRequest<Substrate>? = nil
    
    private var beaconClient: Beacon.WalletClient? = nil {
        didSet {
            started = beaconClient != nil
        }
    }
    
    init() {}
    
    func start() {
        startBeacon()
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
    
    func sendResponse() {
        if let request = awaitingTezosRequest {
            beaconRequest = nil
            awaitingTezosRequest = nil
            
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
        
        if let request = awaitingSubstrateRequest {
            beaconRequest = nil
            awaitingSubstrateRequest = nil
            
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
    }
    
    func pair() {
        self.beaconClient?.pair(with: pairingRequest) { result in
            switch result {
            case .success(_):
                print("Pairing succeeded")
            case let .failure(error):
                print("Failed to pair, got error: \(error)")
            }
        }
    }
    
    func unpair() {
        beaconClient?.removeAllPeers { result in
            switch result {
            case .success(_):
                print("Successfully removed peers")
            case let .failure(error):
                print("Failed to remove peers, got error: \(error)")
            }
        }
    }
    
    private func startBeacon() {
        guard beaconClient == nil else {
            listenForRequests()
            return
        }
        
        do {
            Beacon.WalletClient.create(
                with: .init(
                    name: "iOS Beacon SDK Demo (Wallet)",
                    blockchains: [Tezos.factory, Substrate.factory],
                    connections: [try Transport.P2P.Matrix.connection()]
                )
            ) { result in
                switch result {
                case let .success(client):
                    print("Beacon client created")
                    
                    DispatchQueue.main.async {
                        self.beaconClient = client
                        self.listenForRequests()
                    }
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
                self.beaconClient?.listen(onRequest: self.onTezosRequest)
                self.beaconClient?.listen(onRequest: self.onSubstrateRequest)
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onTezosRequest(_ requestResult: Result<BeaconRequest<Tezos>, Beacon.Error>) {
        onBeaconRequest(requestResult) { result in
            switch result {
            case let .success(request):
                self.awaitingSubstrateRequest = nil
                self.awaitingTezosRequest = request
            case .failure(_):
                break
            }
        }
    }
    
    private func onSubstrateRequest(_ requestResult: Result<BeaconRequest<Substrate>, Beacon.Error>) {
        onBeaconRequest(requestResult) { result in
            switch result {
            case let .success(request):
                self.awaitingTezosRequest = nil
                self.awaitingSubstrateRequest = request
            case .failure(_):
                break
            }
        }
    }
    
    private func onBeaconRequest<B: Blockchain>(_ result: Result<BeaconRequest<B>, Beacon.Error>, completion: @escaping (Result<BeaconRequest<B>, Swift.Error>) -> ()) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try? encoder.encode(request)
            
            DispatchQueue.main.async {
                self.beaconRequest = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.success(request))
            }
        case let .failure(error):
            print("Error while processing incoming messages: \(error)")
            completion(.failure(error))
        }
    }
        
    private func response(from request: BeaconRequest<Tezos>) throws -> BeaconResponse<Tezos> {
        switch request {
        case let .permission(content):
            return .permission(
                try PermissionTezosResponse(from: content, account: Self.exampleTezosAccount(network: content.network))
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
    
    private func response(from request: BeaconRequest<Substrate>) throws -> BeaconResponse<Substrate> {
        switch request {
        case let .permission(content):
            return .permission(
                try PermissionSubstrateResponse(from: content, accounts: [Self.exampleSubstrateAccount(network: content.networks.first!)])
            )
        case let .blockchain(blockchain):
            switch blockchain {
            case let .signPayload(request):
                return .blockchain(.signPayload(try .init(from: request, transactionHash: nil, signature: "0x00050300724867a19e4a9422ac85f3b9a7c4bf5ccf12c2df60d858b216b81329df7165350005020000d22300000b00000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3fde8f6d19d4a685f5edeed50eb55b1755da0bf01e83946f6e41062113042999a", payload: nil)))
            default:
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }
    }
}

extension BeaconRequest: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        if let tezosRequest = self as? BeaconRequest<Tezos> {
            switch tezosRequest {
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
        } else if let substrateRequest = self as? BeaconRequest<Substrate> {
            switch substrateRequest {
            case let .permission(content):
                try content.encode(to: encoder)
            case let .blockchain(blockchain):
                switch blockchain {
                case let .transfer(content):
                    try content.encode(to: encoder)
                case let .signPayload(content):
                    try content.encode(to: encoder)
                }
            }
        } else {
            throw Error.unsupportedBlockchain
        }
    }
    
    enum Error: Swift.Error {
        case unsupportedBlockchain
    }
}
