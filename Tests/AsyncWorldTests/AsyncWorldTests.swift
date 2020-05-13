import XCTest
@testable import AsyncWorld

final class AsyncWorldTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AsyncWorld().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
