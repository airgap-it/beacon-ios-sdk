import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // MARK: Beacon
        testCase(WalletClientTests.allTests),
    ]
}
#endif
