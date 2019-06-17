import XCTest

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicPromise() {
        let expectation = XCTestExpectation(description: "Test basic promise")

        let promise = Promise<Int> { resolve, _ in
            resolve(1)
        }

        promise.then { (num) in
            XCTAssertEqual(num, 1)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }
}
