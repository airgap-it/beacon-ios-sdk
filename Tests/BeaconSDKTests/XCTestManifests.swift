import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        // MARK: Beacon
        testCase(BeaconTests.allTests),
        testCase(ClientTests.allTests),
        
        
        // MARK: Controller
        testCase(ConnectionControllerTests.allTests),
        testCase(MessageControllerTests.allTests),

        
        // MARK: Crypto
        testCase(CryptoTests.allTests),
        
    
        // MARK: Common
        testCase(AccountUtilsTests.allTests),
        testCase(DistinguishableListenerTests.allTests),
        testCase(HexStringTests.allTests),
        testCase(LazyWeakReferenceTests.allTests),
        testCase(SingleCallTests.allTests),
        testCase(TryUtilsTests.allTests),
        
        testCase(ArrayAdditionsTests.allTests),
        testCase(DictionaryAdditionsTests.allTests),
        testCase(ResultAdditionsTests.allTests),
        testCase(StringAdditionsTests.allTests),
    ]
}
#endif
