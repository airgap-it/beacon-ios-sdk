//
//  WalletClientTests.swift
//  BeaconClientWalletTests
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
import Common

@testable import BeaconCore
@testable import BeaconClientWallet

class WalletClientTests: XCTestCase {
    
    private var beaconClient: Beacon.WalletClient!
    private var storage: MockStorage!
    private var secureStorage: SecureStorage!
    private var storageManager: StorageManager!
    private var connectionController: MockConnectionController!
    private var messageController: MockMessageController!
    private var identifierCreator: MockIdentifierCreator!
    private var crypto: Crypto!
    
    private let dAppVersion: String = "2"
    private let dAppID: String = "dAppID"
    private let connectionKind: Beacon.Connection.Kind = .p2p
    private let beaconID: String = "beaconID"
    
    override func setUpWithError() throws {
        identifierCreator = MockIdentifierCreator()
        crypto = Crypto(provider: SodiumCryptoProvider())
        
        storage = MockStorage()
        secureStorage = MockSecureStorage()
        storageManager = StorageManager(storage: storage, secureStorage: secureStorage, identifierCreator: identifierCreator)
        
        connectionController = MockConnectionController()
        messageController = MockMessageController(storageManager: storageManager, connectionKind: connectionKind)
        
        messageController.dAppID = dAppID
        messageController.dAppVersion = dAppVersion
        
        beaconClient = Beacon.WalletClient(
            name: "mockApp",
            beaconID: beaconID,
            storageManager: storageManager,
            connectionController: connectionController,
            messageController: messageController,
            crypto: crypto
        )
    }
    
    override func tearDownWithError() throws {
        beaconClient = nil
        messageController = nil
        connectionController = nil
        storageManager = nil
        storage = nil
    }
    
    func testClientConnectsToDApp() {
        let testExpectation = expectation(description: "Client connects to dApp")
        
        beaconClient.connect { result in
            switch result {
            case .success(_):
                break
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testBeaconClientConnectsToDApp timeout: \(error)")
            }
        }
    }
    
    func testClientFailsToConnectToDAppOnInternalError() {
        let testExpectation = expectation(description: "Client connect")
        connectionController.isFailing = true
        
        beaconClient.connect { result in
            switch result {
            case .success(_):
                XCTFail("Expected error")
            case .failure(_):
                break
            }
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testBeaconClientConnectsToDApp timeout: \(error)")
            }
        }
    }
    
    func testClientListensForRequests() {
        let testExpectation = expectation(description: "Client listens for requests")
        
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        storage.set([appMetadata]) { _ in }
        
        let origin = Beacon.Origin.init(kind: connectionKind, id: dAppID)
        
        let requests = beaconRequests(senderID: dAppID, appMetadata: appMetadata, origin: origin)
        let versioned = beaconVersionedRequests(senderID: dAppID, requests: requests)
        connectionController.register(messages: versioned.map { (origin, $0) })
        
        var received: [BeaconRequest<MockBlockchain>] = []
        beaconClient.listen { (result: Result<BeaconRequest<MockBlockchain>, Beacon.Error>) in
            switch result {
            case let .success(request):
                received.append(request)
                if received.count == versioned.count {
                    XCTAssertTrue(
                        versioned.map { ($0, origin) } == self.messageController.onIncomingCalls,
                        "Expected messageController#onIncoming to be called with the specified versioned requests and origin"
                    )
                    XCTAssertEqual(requests, received, "Received requests don't match expected")
                    testExpectation.fulfill()
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
                testExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testBeaconClientListensForRequests timeout: \(error)")
            }
        }
    }
    
    func testClientNotifiesListenerOnErrors() {
        let testExpectation = expectation(description: "Client notifies listener on errors")
        
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        storage.set([appMetadata]) { _ in }
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        
        let requests = beaconRequests(senderID: dAppID, appMetadata: appMetadata, origin: origin)
        let versioned = beaconVersionedRequests(senderID: dAppID, requests: requests).map { (origin, $0) }
        connectionController.register(messages: versioned)
        connectionController.isFailing = true
        
        testExpectation.expectedFulfillmentCount = versioned.count
        
        beaconClient.listen { (result: Result<BeaconRequest<MockBlockchain>, Beacon.Error>) in
            switch result {
            case .success(_):
                XCTFail("Expected error")
            case .failure:
                break
            }
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testClientNotifiesListenerOnErrors timeout: \(error)")
            }
        }
    }
    
    func testClientResponds() throws {
        let testExpectation = expectation(description: "Client responds with a response message")
        
        let responses = beaconResponses(version: dAppVersion)
        let versioned = beaconVersionedResponses(senderID: beaconID, responses: responses)
        
        responses.forEachAsync(body: { self.beaconClient.respond(with: $0, completion: $1) }) { results in
            XCTAssertTrue(
                responses.map { (BeaconMessage.response($0), self.beaconID) } == self.messageController.onOutgoingCalls(),
                "Expected messageController#onOutgoing to be called with specified responses and senderID"
            )
            XCTAssertEqual(
                versioned.map { BeaconConnectionMessage(origin: Beacon.Origin(kind: self.connectionKind, id: self.beaconID), content: $0) },
                self.connectionController.sendMessageCalls,
                "Expected connectionController#sendMessage to be called with converted versioned responses"
            )
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testClientResponds timeout: \(error)")
            }
        }
    }
    
    func testClientAddsPeers() throws {
        let testExpectation = expectation(description: "Client adds new peers")
        
        storage.peers = []
        let newPeers = p2pPeers(n: 2).map { Beacon.Peer.p2p($0) }
        
        beaconClient.add(newPeers) { result in
            switch result {
            case .success(_):
                XCTAssertEqual(self.storage.peers, newPeers, "Expected storage to contain the added peers")
                XCTAssertEqual(
                    [newPeers],
                    self.connectionController.onNewPeersCalls,
                    "Expected connectionController to be notified with new peers"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testClientAddsPeers timeout: \(error)")
            }
        }
    }
    
    func testClientRemovesPeers() throws {
        let testExpectation = expectation(description: "Client removes peers")
        
        let peers = p2pPeers(n: 4).map { Beacon.Peer.p2p($0) }
        let toKeep = Array(peers[0..<2])
        let toRemove = Array(peers[2...])
        storage.peers = peers
        
        beaconClient.remove(toRemove) { result in
            switch result {
            case .success(_):
                XCTAssertEqual(self.storage.peers, toKeep, "Expected storage not to contain the removed peers")
                XCTAssertEqual(
                    [toRemove],
                    self.connectionController.onDeletedPeerCalls,
                    "Expected connectionController to be notified with removed peers"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testClientRemovesPeers timeout: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testClientConnectsToDApp", testClientConnectsToDApp),
        ("testClientFailsToConnectToDAppOnInternalError", testClientFailsToConnectToDAppOnInternalError),
        ("testClientListensForRequests", testClientListensForRequests),
        ("testClientNotifiesListenerOnErrors", testClientNotifiesListenerOnErrors),
        ("testClientResponds", testClientResponds),
        ("testClientAddsPeers", testClientAddsPeers),
        ("testClientsRemovesPeers", testClientRemovesPeers),
    ]
}
