//
//  MessageControllerTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
import Common

@testable import BeaconCore

class MessageControllerTests: XCTestCase {
    
    private var messageController: MessageController!
    private var blockchainRegistry: MockBlockchainRegistry!
    private var storage: MockStorage!
    private var secureStorage: MockSecureStorage!
    private var identifierCreator: MockIdentifierCreator!
    private var time: MockTime!
    
    private let dAppID = "01"
    private let dAppVersion = "2"
    
    private let beaconID = "00"

    override func setUpWithError() throws {
        blockchainRegistry = MockBlockchainRegistry()
        storage = MockStorage()
        secureStorage = MockSecureStorage()
        blockchainRegistry = MockBlockchainRegistry()
        identifierCreator = MockIdentifierCreator()
        time = MockTime()
        
        messageController = MessageController(
            blockchainRegistry: blockchainRegistry,
            storageManager: StorageManager(storage: storage, secureStorage: secureStorage, blockchainRegistry: blockchainRegistry, identifierCreator: identifierCreator),
            identifierCreator: identifierCreator,
            time: time
        )
    }

    override func tearDownWithError() throws {
        messageController = nil
        time = nil
        identifierCreator = nil
        storage = nil
        blockchainRegistry = nil
        
        clearBeacon()
    }

    func testControllerConvertsIncomingMessages() throws {
        let testExpectation = expectation(description: "MessageController converts incoming messages")
        
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        storage.appMetadata = [appMetadata]
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        let requests = beaconRequests(senderID: dAppID, appMetadata: appMetadata, origin: origin)
        let versionedRequests = beaconVersionedRequests(senderID: dAppID, requests: requests)
        
        testExpectation.expectedFulfillmentCount = versionedRequests.count
        
        for (index, versioned) in versionedRequests.enumerated() {
            messageController.onIncoming(versioned, with: origin) { (result: Result<BeaconMessage<MockBlockchain>, Swift.Error>) in
                switch result {
                case let .success(request):
                    XCTAssertEqual(.request(requests[index]), request, "Expected converted incoming message to match the specified request")
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)")
                }
                testExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConvertsIncomingMessages timeout: \(error)")
            }
        }
    }
    
    func testControllerConvertsOutgoingMessages() throws {
        let testExpectation = expectation(description: "MessageController converts outgoing messages")
        
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        storage.appMetadata = [appMetadata]
        
        let requestOrigin = Beacon.Origin.p2p(id: dAppID)
        let pendingRequest: BeaconMessage<MockBlockchain> = .request(.permission(permissionBeaconRequest(version: dAppVersion)))
        let versionedPendingRequest = try VersionedBeaconMessage(
            from: pendingRequest,
            senderID: dAppID
        )
        
        let responses = beaconResponses(id: pendingRequest.id, version: dAppVersion, requestOrigin: requestOrigin)
        let versionedResponses = beaconVersionedResponses(senderID: beaconID, responses: responses)
        
        testExpectation.expectedFulfillmentCount = responses.count
        
        initBeacon { _ in
            for (index, response) in responses.enumerated() {
                self.messageController.onIncoming(versionedPendingRequest, with: requestOrigin) { (_: Result<BeaconMessage<MockBlockchain>, Swift.Error>) in
                    self.messageController.onOutgoing(.response(response), with: self.beaconID, terminal: false) { result in
                        switch result {
                        case let .success((origin, versioned)):
                            XCTAssertEqual(requestOrigin, origin, "Expected returned origin to match the request origin")
                            XCTAssertEqual(
                                versionedResponses[index],
                                versioned,
                                "Expected converted outgoing message to match the specified versioned response"
                            )
                        case let .failure(error):
                            XCTFail("Unexpected error: \(error)")
                        }
                        
                        testExpectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConvertsOutgoingMessages timeout: \(error)")
            }
        }
    }
    
    func testControllerFailsOnOutgoingMessageIfNoPendingRequests() throws {
        let testExpectation = expectation(description: "MessageController fails on outgoing message if no pending requests")
        
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        storage.appMetadata = [appMetadata]
        
        let responses = beaconResponses()
        
        testExpectation.expectedFulfillmentCount = responses.count
        
        for response in responses {
            messageController.onOutgoing(.response(response), with: beaconID, terminal: true) { result in
                switch result {
                case .success(_):
                    XCTFail("Expected error")
                case let .failure(error):
                    switch error as? Beacon.Error {
                    case let .noPendingRequest(id: id):
                        XCTAssertEqual(response.id, id, "Expected error to contain the response ID")
                    default:
                        XCTFail("Expected .noPendingRequest error")
                    }
                }
                
                testExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerFailsOnOutgoingMessageIfNoPendingRequests timeout: \(error)")
            }
        }
    }
    
    func testControllerSavesAppMetadataOnIncomingPermissionRequest() throws {
        let testExpectation = expectation(description: "MessageController saves AppMetadata on incoming PermissionRequest")
        
        storage.appMetadata = []
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        let appMetadata = AnyAppMetadata(senderID: dAppID, name: "mockApp")
        let permissionRequest: BeaconMessage<MockBlockchain> = .request(.permission(permissionBeaconRequest(appMetadata: appMetadata, version: dAppVersion)))
        let versionedRequest = try VersionedBeaconMessage(
            from: permissionRequest,
            senderID: dAppID
        )
        
        messageController.onIncoming(versionedRequest, with: origin) { (result: Result<BeaconMessage<MockBlockchain>, Swift.Error>) in
            switch result {
            case .success(_):
                XCTAssertEqual(
                    [appMetadata],
                    self.storage.appMetadata,
                    "Expected AppMetadata from PermissionRequest to be saved in the storage"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerSavesAppMetadataOnIncomingPermissionRequest timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testControllerConvertsIncomingMessages", testControllerConvertsIncomingMessages),
        ("testControllerConvertsOutgoingMessages", testControllerConvertsOutgoingMessages),
        ("testControllerFailsOnOutgoingMessageIfNoPendingRequests", testControllerFailsOnOutgoingMessageIfNoPendingRequests),
        ("testControllerSavesAppMetadataOnIncomingPermissionRequest", testControllerSavesAppMetadataOnIncomingPermissionRequest),
    ]
}
