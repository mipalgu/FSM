import XCTest
@testable import FSMTests

XCTMain([
     testCase(CArrayTests.allTests),
     testCase(FactoriesTests.allTests),
     testCase(HashTableCycleDetectorTests.allTests),
     testCase(MultipleExternalsSpinnerConstructorTests.allTests),
     //testCase(SpinnerTests.allTests),
])
