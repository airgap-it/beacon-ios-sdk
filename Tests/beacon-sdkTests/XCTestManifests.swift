import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(beacon_sdkTests.allTests),
    ]
}
#endif
