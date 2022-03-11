import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // MARK: Wallet
        testCase(WalletTests.allTests),
    ]
}
#endif
