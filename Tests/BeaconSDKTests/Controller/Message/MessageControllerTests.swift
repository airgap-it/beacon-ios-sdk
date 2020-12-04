//
//  MessageControllerTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class MessageControllerTests: XCTestCase {
    
    private var messageController: MessageController!
    private var coinRegistry: MockCoinRegistry!
    private var storage: MockStorage!
    private var accountUtils: MockAccountUtils!
    private var timeUtils: MockTimeUtils!
    
    private let dAppID = "01"
    private let dAppVersion = "2"
    
    private let beaconID = "00"

    override func setUpWithError() throws {
        coinRegistry = MockCoinRegistry()
        storage = MockStorage()
        accountUtils = MockAccountUtils()
        timeUtils = MockTimeUtils()
        
        messageController = MessageController(
            coinRegistry: coinRegistry,
            storageManager: StorageManager(storage: storage, accountUtils: accountUtils),
            accountUtils: accountUtils,
            timeUtils: timeUtils
        )
    }

    override func tearDownWithError() throws {
        messageController = nil
        timeUtils = nil
        accountUtils = nil
        storage = nil
        coinRegistry = nil
    }

    func testControllerConvertsIncomingMessages() throws {
        let testExpectation = expectation(description: "MessageController converts incoming messages")
        
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
        storage.appMetadata = [appMetadata]
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        let requests = beaconRequests(senderID: dAppID, appMetadata: appMetadata, origin: origin)
        let versionedRequests = beaconVersionedRequests(senderID: dAppID, requests: requests)
        
        testExpectation.expectedFulfillmentCount = versionedRequests.count
        
        for (index, versioned) in versionedRequests.enumerated() {
            messageController.onIncoming(versioned, with: origin) { result in
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
        
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
        storage.appMetadata = [appMetadata]
        
        let requestOrigin = Beacon.Origin.p2p(id: dAppID)
        let pendingRequest = permissionBeaconRequest(version: dAppVersion)
        let versionedPendingRequest = try Beacon.Message.Versioned(
            from: .request(.permission(pendingRequest)),
            senderID: dAppID
        )
        
        let responses = beaconResponses(id: pendingRequest.id, version: dAppVersion, requestOrigin: requestOrigin)
        let versionedResponses = beaconVersionedResponses(senderID: beaconID, responses: responses)
        
        testExpectation.expectedFulfillmentCount = responses.count
        
        for (index, response) in responses.enumerated() {
            messageController.onIncoming(versionedPendingRequest, with: requestOrigin) { _ in
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
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConvertsOutgoingMessages timeout: \(error)")
            }
        }
    }
    
    func testControllerFailsOnOutgoingMessageIfNoPendingRequests() throws {
        let testExpectation = expectation(description: "MessageController fails on outgoing message if no pending requests")
        
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
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
                        XCTAssertEqual(response.common.id, id, "Expected error to contain the response ID")
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
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
        let permissionRequest = permissionBeaconRequest(appMetadata: appMetadata, version: dAppVersion)
        let versionedRequest = try Beacon.Message.Versioned.init(
            from: .request(.permission(permissionRequest)),
            senderID: dAppID
        )
        
        messageController.onIncoming(versionedRequest, with: origin) { result in
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
    
    func testControllerSavesPermissionOnOutgoingPermissionResponse() throws {
        let testExpectation = expectation(description: "MessageController saves Permission on outgoing PermissionResponse")
        
        storage.permissions = []
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
        let permissionRequest = permissionBeaconRequest(appMetadata: appMetadata, version: dAppVersion)
        let versionedRequest = try Beacon.Message.Versioned.init(
            from: .request(.permission(permissionRequest)),
            senderID: dAppID
        )
        
        let publicKey = "publicKey"
        let network = Beacon.Network(type: .custom, name: "custom", rpcURL: "customURL")
        let scopes = [Beacon.Permission.Scope.operationRequest]
        let permissionResponse = permissionBeaconResponse(
            id: permissionRequest.id,
            publicKey: publicKey,
            network: network,
            scopes: scopes
        )
        
        messageController.onIncoming(versionedRequest, with: origin) { _ in
            self.messageController.onOutgoing(.response(.permission(permissionResponse)), with: self.beaconID, terminal: true) { result in
                switch result {
                case .success(_):
                    XCTAssertEqual(
                        [Beacon.Permission(
                            accountIdentifier: publicKey,
                            address: publicKey,
                            network: network,
                            scopes: scopes,
                            senderID: self.dAppID,
                            appMetadata: appMetadata,
                            publicKey: publicKey,
                            connectedAt: 0
                        )],
                        self.storage.permissions,
                        "Expected Permission to be saved in the storage"
                    )
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)")
                }
                
                testExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerSavesPermissionOnOutgoingPermissionResponse timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testControllerConvertsIncomingMessages", testControllerConvertsIncomingMessages),
        ("testControllerConvertsOutgoingMessages", testControllerConvertsOutgoingMessages),
        ("testControllerFailsOnOutgoingMessageIfNoPendingRequests", testControllerFailsOnOutgoingMessageIfNoPendingRequests),
        ("testControllerSavesAppMetadataOnIncomingPermissionRequest", testControllerSavesAppMetadataOnIncomingPermissionRequest),
        ("testControllerSavesPermissionOnOutgoingPermissionResponse", testControllerSavesPermissionOnOutgoingPermissionResponse),
    ]
}
