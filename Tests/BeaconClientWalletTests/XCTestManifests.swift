import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // MARK: WalletClient
        testCase(WalletClientTests.allTests),
    ]
}
#endif
