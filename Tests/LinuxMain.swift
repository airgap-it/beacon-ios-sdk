import XCTest

import BeaconCoreTests
import BeaconClientWalletTests
import BeaconBlockchainTezosTests

var tests = [XCTestCaseEntry]()
tests += BeaconCoreTests.allTests()
tests += BeaconClientWalletTests.allTests()
tests += BeaconBlockchainTezosTests.allTests()
XCTMain(tests)
