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

    func testChainPromises() {
        let expectation = XCTestExpectation(description: "Test chaining promises")

        func work1(_ string: String) -> Promise<String> {
            return Promise { resolve, _ in
                resolve(string)
            }
        }

        func work2(_ string: String) -> Promise<Int> {
            return Promise { resolve, _ in
                resolve(Int(string) ?? 0)
            }
        }

        func work3(_ number: Int) -> Int {
            return number * number
        }

        work1("10").then { string in
            return work2(string)
        }.then { number in
            return work3(number)
        }.then { number in
            XCTAssertEqual(number, 100)
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }
}
