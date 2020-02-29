import XCTest
@testable import FSMTests
@testable import ModelCheckingTests

XCTMain([
     testCase(CArrayTests.allTests),
     testCase(HashTableCycleDetectorTests.allTests),
     testCase(MultipleExternalsSpinnerConstructorTests.allTests)
     //testCase(SpinnerTests.allTests),
])
