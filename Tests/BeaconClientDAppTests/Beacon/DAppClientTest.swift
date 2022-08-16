//
//  DAppClientTest.swift
//  
//
//  Created by Julia Samol on 15.08.22.
//

import XCTest
import Common

@testable import BeaconCore
@testable import BeaconClientDApp

class DAppClientTest: XCTestCase {
    
    private var beaconClient: Beacon.DAppClient!
    
    private var storage: MockStorage!
    private var secureStorage: SecureStorage!
    private var storageManager: StorageManager!
    
    private var connectionController: MockConnectionController!
    private var messageController: MockMessageController!
    private var accountController: MockAccountController!
    
    private var blockchainRegistry: MockBlockchainRegistry!
    private var identifierCreator: MockIdentifierCreator!
    private var crypto: Crypto!
    private var serializer: MockSerializer!
    
    private let app: Beacon.Application = .init(
        keyPair: .init(secretKey: [0], publicKey: [0]),
        name: "mockApp"
    )
    
    private let dAppVersion: String = "3"
    private let walletID: String = "walletID"
    private let connectionKind: Beacon.Connection.Kind = .p2p
    private let beaconID: String = "beaconID"
    
    override func setUpWithError() throws {
        identifierCreator = MockIdentifierCreator()
        crypto = Crypto(provider: SodiumCryptoProvider())
        serializer = MockSerializer()
        
        storage = MockStorage()
        secureStorage = MockSecureStorage()
        blockchainRegistry = MockBlockchainRegistry()
        storageManager = StorageManager(storage: storage, secureStorage: secureStorage, blockchainRegistry: blockchainRegistry, identifierCreator: identifierCreator)
        
        connectionController = MockConnectionController()
        messageController = MockMessageController(storageManager: storageManager, connectionKind: connectionKind)
        accountController = MockAccountController()
        
        messageController.dAppID = walletID
        messageController.dAppVersion = dAppVersion
        
        beaconClient = Beacon.DAppClient(
            app: app,
            beaconID: beaconID,
            storageManager: storageManager,
            connectionController: connectionController,
            messageController: messageController,
            accountController: accountController,
            crypto: crypto,
            serializer: serializer,
            identifierCreator: identifierCreator
        )
    }
    
    override func tearDownWithError() throws {
        beaconClient = nil
        storage = nil
        secureStorage = nil
        storageManager = nil
        connectionController = nil
        messageController = nil
        accountController = nil
        blockchainRegistry = nil
        identifierCreator = nil
        crypto = nil
        serializer = nil
    }
    
    func testClientConnectsToWallet() {
        let testExpectation = expectation(description: "Client connects to wallet")
        
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
                XCTFail("testBeaconClientConnectsToWallet timeout: \(error)")
            }
        }
    }
    
    func testClientFailsToConnectToWalletOnInternalError() {
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
                XCTFail("testBeaconClientConnectsToWallet timeout: \(error)")
            }
        }
    }
    
    func testClientListensForResponses() {
        let testExpectation = expectation(description: "Client listens for responses")
        
        let origin = Beacon.Connection.ID(kind: connectionKind, id: walletID)
        let destination = Beacon.Connection.ID(kind: connectionKind, id: HexString(from: app.keyPair.publicKey).asString())
        
        let responses = beaconResponses(version: dAppVersion, destination: destination)
        let versioned = beaconVersionedResponses(senderID: walletID, responses: responses)
        connectionController.register(messages: versioned.map { (origin, $0) })
        
        var received: [BeaconResponse<MockBlockchain>] = []
        beaconClient.listen { (result: Result<BeaconResponse<MockBlockchain>, Beacon.Error>) in
            switch result {
            case let .success(response):
                received.append(response)
                if received.count == versioned.count {
                    XCTAssertTrue(
                        versioned.map { ($0, origin) } == self.messageController.onIncomingCalls(),
                        "Expected messageController#onIncoming to be called with the specified versioned response and origin"
                    )
                    XCTAssertEqual(responses, received, "Received responses don't match expected")
                    testExpectation.fulfill()
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
                testExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testBeaconClientListensForResponses timeout: \(error)")
            }
        }
    }
    
    func testClientNotifiesListenerOnErrors() {
        let testExpectation = expectation(description: "Client notifies listener on errors")
        
        let origin = Beacon.Connection.ID(kind: connectionKind, id: walletID)
        let destination = Beacon.Connection.ID(kind: connectionKind, id: HexString(from: app.keyPair.publicKey).asString())
        
        let responses = beaconResponses(version: dAppVersion, destination: destination)
        let versioned = beaconVersionedResponses(senderID: walletID, responses: responses).map { (origin, $0) }
        connectionController.register(messages: versioned)
        connectionController.isFailing = true
        
        testExpectation.expectedFulfillmentCount = versioned.count
        
        beaconClient.listen { (result: Result<BeaconResponse<MockBlockchain>, Beacon.Error>) in
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
    
    func testClientSendsRequests() throws {
        let testExpectation = expectation(description: "Client sends request messages")
        
        let origin = Beacon.Connection.ID.init(kind: connectionKind, id: beaconID)
        
        let requests = beaconRequests(origin: origin, version: dAppVersion)
        let versioned = beaconVersionedRequests(senderID: beaconID, requests: requests)
        
        requests.forEachAsync(body: { self.beaconClient.request(with: $0, completion: $1) }) { results in
            XCTAssertTrue(
                requests.map { (BeaconMessage.request($0), self.beaconID) } == self.messageController.onOutgoingCalls(),
                "Expected messageController#onOutgoing to be called with specified requests and senderID"
            )
            XCTAssertEqual(
                versioned.map { BeaconOutgoingConnectionMessage(destination: Beacon.Connection.ID(kind: self.connectionKind, id: self.beaconID), content: $0) },
                self.connectionController.sendMessageCalls(),
                "Expected connectionController#sendMessage to be called with converted versioned requests"
            )
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testClientSendsRequests timeout: \(error)")
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
        ("testClientConnectsToDApp", testClientConnectsToWallet),
        ("testClientFailsToConnectToDAppOnInternalError", testClientFailsToConnectToWalletOnInternalError),
        ("testClientListensForRequests", testClientListensForResponses),
        ("testClientNotifiesListenerOnErrors", testClientNotifiesListenerOnErrors),
        ("testClientResponds", testClientSendsRequests),
        ("testClientAddsPeers", testClientAddsPeers),
        ("testClientsRemovesPeers", testClientRemovesPeers),
    ]
}
