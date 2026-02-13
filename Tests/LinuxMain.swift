import XCTest

import OctezConnectCoreTests
import OctezConnectClientWalletTests
import OctezConnectBlockchainTezosTests

var tests = [XCTestCaseEntry]()
tests += OctezConnectCoreTests.allTests()
tests += OctezConnectClientWalletTests.allTests()
tests += OctezConnectBlockchainTezosTests.allTests()
XCTMain(tests)
