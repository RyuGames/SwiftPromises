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

    func testAll() {
        let expectation = XCTestExpectation(description: "Test all")

        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                resolve(15)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: {
                resolve(4)
            })
        }

        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                resolve(55)
            })
        }

        let promise4 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                resolve(1)
            })
        }

        let promise5 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                resolve(11)
            })
        }

        let expected: Int = 15 + 4 + 55 + 1 + 11
        all([promise, promise2, promise3, promise4, promise5]).then ({ (numbers) in
            var total = 0
            for number in numbers {
                total += number
            }

            XCTAssertEqual(total, expected)
            XCTAssertEqual(numbers.count, 5)
            expectation.fulfill()
        }).catch ({ (err) in
            XCTFail()
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllCatch() {
        let expectation = XCTestExpectation(description: "Test all catch")

        let promise = Promise<Int> { resolve, reject in
            promiseQueue.asyncAfter(deadline: .now() + 2, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        all([promise]).then ({ _ in
            XCTFail()
            expectation.fulfill()
        }).catch ({ (err) in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Error")
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllEmpty() {
        let expectation = XCTestExpectation(description: "Test all empty")

        let promises: [Promise<Any>] = []
        all(promises).then ({ (numbers) in
            XCTAssertEqual(numbers.count, 0)
            expectation.fulfill()
        }).catch ({ (err) in
            XCTFail()
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllTimeout() {
        let expectation = XCTestExpectation(description: "Test all with timeout")

        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                resolve(1)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                resolve(11)
            })
        }

        all([promise1, promise2], timeout: 1).then ({ (numbers) in
            XCTFail()
            expectation.fulfill()
        }).catch ({ (err) in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Timeout")
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testAwait() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                resolve(1)
            })
        }

        guard let value = try? await(promise: promise) else {
            XCTFail()
            return
        }

        XCTAssertEqual(value, 1)
    }

    func testBasicPromise() {
        let expectation = XCTestExpectation(description: "Test basic promise")

        let promise = Promise<Int> { resolve, _ in
            resolve(1)
        }

        promise.then ({ (num) in
            XCTAssertEqual(num, 1)
            expectation.fulfill()
        }).catch ({ _ in
            XCTFail()
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testCatching() {
        let expectation = XCTestExpectation(description: "Test catching")

        let promise = Promise<Bool> { _, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        promise.catch { _ in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testChainCatching() {
        let expectation = XCTestExpectation(description: "Test chaining catching")

        func work1(_ string: String) -> Promise<String> {
            return Promise { resolve, _ in
                resolve(string)
            }
        }

        func work2(_ string: String) -> Promise<Int> {
            return Promise { _, reject in
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            }
        }

        work1("10").then ({ string in
            return work2(string)
        }).then ({ number in
            XCTFail()
            expectation.fulfill()
        }).catch ({ err in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Error")
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 5)
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

        work1("10").then ({ string in
            return work2(string)
        }).then ({ number in
            return work3(number)
        }).then ({ number in
            XCTAssertEqual(number, 100)
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }
    
    func testChainingSimplified() {
        let expectation = XCTestExpectation(description: "Test chaining simplified")

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

        work1("10").then(work2).then(work3).then ({ number in
            XCTAssertEqual(number, 100)
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }
}
