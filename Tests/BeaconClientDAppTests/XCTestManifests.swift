import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // MARK: DAppClient
        testCase(DAppClientTest.allTests),
    ]
}
#endif
