import XCTest
@testable import LaunchPadManagerDBHelper

@available(macOS 13, *)
final class LaunchPadManagerDBHelperTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let helper = try LaunchPadManagerDBHelper()
        let apps = try helper.getAllAppInfos()
        print(apps)
    }
}
