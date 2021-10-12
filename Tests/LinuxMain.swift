import XCTest

import BeaconCoreTests

var tests = [XCTestCaseEntry]()
tests += BeaconSDKTests.allTests()
tests += BeaconClientWalletTests.allTests()
XCTMain(tests)
