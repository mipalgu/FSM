import XCTest
@testable import FSMTests

XCTMain([
     testCase(BehaviourTests.allTests),
     testCase(CArrayTests.allTests),
     testCase(FactoriesTests.allTests),
     testCase(GenericWhiteboardTests.allTests),
     testCase(SpinnerTests.allTests),
     testCase(WhiteboardBehaviourTests.allTests)
])
