//
//  StorageManagerTests.swift
//  
//
//  Created by Julia Samol on 18.05.22.
//

import XCTest
@testable import BeaconCore
import Common

class StorageManagerTests: XCTestCase {
    
    private var storageManager: StorageManager!
    private var storage: MockStorage!
    private var secureStorage: MockSecureStorage!

    override func setUpWithError() throws {
        storage = MockStorage()
        secureStorage = MockSecureStorage()
        
        storageManager = StorageManager(
            storage: storage,
            secureStorage: secureStorage,
            blockchainRegistry: MockBlockchainRegistry(mockBlockchain: .init(storageExtension: .init(storage: MockExtendedStorage(storage: storage)))),
            identifierCreator: MockIdentifierCreator()
        )
    }

    override func tearDownWithError() throws {
        storageManager = nil
        storage = nil
        secureStorage = nil
    }
    
    func testRemovePermissions() throws {
        let permissions = [
            MockBlockchain.Permission(accountID: "1", senderID: "senderId", connectedAt: 0),
            MockBlockchain.Permission(accountID: "2", senderID: "senderId", connectedAt: 0),
            MockBlockchain.Permission(accountID: "3", senderID: "senderId", connectedAt: 0)
        ]
        
        storage.permissions = permissions
        let toRemove = permissions[1]
        
        let testExpectation = expectation(description: "StorageManager completes")
        storageManager.removePermissions(where: { (permission: MockBlockchain.Permission) in permission.accountID == toRemove.accountID }) { result in
            switch result {
            case .success(_):
                XCTAssertEqual(permissions.filter({ $0.accountID != toRemove.accountID }), self.storage.permissions)
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testRemovePermissions timeout: \(error)")
            }
        }
    }
    
    func testRemoveAllPermissions() throws {
        let permissions = [
            MockBlockchain.Permission(accountID: "1", senderID: "senderId", connectedAt: 0),
            MockBlockchain.Permission(accountID: "2", senderID: "senderId", connectedAt: 0),
            MockBlockchain.Permission(accountID: "3", senderID: "senderId", connectedAt: 0)
        ]
        
        storage.permissions = permissions
        
        let testExpectation = expectation(description: "StorageManager completes")
        storageManager.removeAllPermissions { result in
            switch result {
            case .success(_):
                XCTAssertTrue(self.storage.permissions.isEmpty, "Expected all permissions to be removed")
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testRemoveAllPermissions timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testRemovePermissions", testRemovePermissions),
        ("testRemoveAllPermissions", testRemoveAllPermissions),
    ]
}
