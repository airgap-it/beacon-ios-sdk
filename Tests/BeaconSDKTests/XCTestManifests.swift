import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BeaconTests.allTests),
        testCase(ClientTests.allTests),
        testCase(CryptoTests.allTests),
        testCase(HexStringTests.allTests),
    ]
}
#endif
