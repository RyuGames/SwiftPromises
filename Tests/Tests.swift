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
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                resolve(15)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                resolve(4)
            })
        }

        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(55)
            })
        }

        let promise4 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(1)
            })
        }

        let promise5 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(11)
            })
        }

        let expected: Int = 15 + 4 + 55 + 1 + 11
        all([promise, promise2, promise3, promise4, promise5]).then { (numbers) in
            var total = 0
            for number in numbers {
                total += number
            }

            XCTAssertEqual(total, expected)
            XCTAssertEqual(numbers.count, 5)
            expectation.fulfill()
        }.catch { (err) in
            XCTFail()
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllCatch() {
        let expectation = XCTestExpectation(description: "Test all catch")

        let promise = Promise<Int> { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        all([promise]).then { _ in
            XCTFail()
            expectation.fulfill()
        }.catch { (err) in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Error")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllEmpty() {
        let expectation = XCTestExpectation(description: "Test all empty")

        let promises: [Promise<Any>] = []
        all(promises).then { (numbers) in
            XCTAssertEqual(numbers.count, 0)
            expectation.fulfill()
        }.catch { (err) in
            XCTFail()
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAllTimeout() {
        let expectation = XCTestExpectation(description: "Test all with timeout")

        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(1)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(11)
            })
        }

        all([promise1, promise2], timeout: 100).then { (numbers) in
            XCTFail()
            expectation.fulfill()
        }.catch { (err) in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Timeout")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAlwaysBasic() {
        let expectation = XCTestExpectation(description: "Test always basic")

        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(1)
            })
        }

        promise1.then { (val) in
            print("Then")
            XCTAssertEqual(val, 1)
        }.always {
            print("Always")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAlwaysCatch() {
        let expectation = XCTestExpectation(description: "Test always catch")

        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(1)
            })
        }

        promise1.then { (val) in
            print("Then")
            XCTAssertEqual(val, 1)
        }.catch { _ in
            print("Catch")
            XCTFail()
        }.always {
            print("Always")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAlwaysCatchReject() {
        let expectation = XCTestExpectation(description: "Test always catch reject")
        let error = NSError(domain: "Error", code: -500, userInfo: [:])

        let promise1 = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                reject(error)
            })
        }

        promise1.then { (val) in
            print("Then")
            XCTFail()
        }.catch { (err) in
            print("Catch")
            XCTAssertEqual(error.domain, (err as NSError).domain)
        }.always {
            print("Always")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAlwaysChaining() {
        let expectation = XCTestExpectation(description: "Test always chaining")

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
        }.always {
            print("Always")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAlwaysChainingCatch() {
        let expectation = XCTestExpectation(description: "Test always chaining catch")

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

        work1("10").then { string in
            return work2(string)
        }.then { number in
            XCTFail()
        }.catch { err in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Error")
        }.always {
            print("Always")
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testAwait() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(1)
            })
        }

        guard let value = try? await(promise) else {
            XCTFail()
            return
        }

        XCTAssertEqual(value, 1)
    }

    func testAwaitMultiple() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(15)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(4)
            })
        }

        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(55)
            })
        }

        let promise4 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(1)
            })
        }

        let promise5 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(11)
            })
        }

        guard let value = try? await(promise) else {
            XCTFail()
            return
        }

        guard let value2 = try? await(promise2) else {
            XCTFail()
            return
        }

        guard let value3 = try? await(promise3) else {
            XCTFail()
            return
        }

        guard let value4 = try? await(promise4) else {
            XCTFail()
            return
        }

        guard let value5 = try? await(promise5) else {
            XCTFail()
            return
        }

        let total: Int = value + value2 + value3 + value4 + value5
        let expected: Int = 15 + 4 + 55 + 1 + 11
        XCTAssertEqual(total, expected)
    }

    func testAwaitReject() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        do {
            let _ = try await(promise)
            XCTFail()
        } catch let error {
            let error = error as NSError
            let message = error.domain
            XCTAssertEqual(message, "Error")
        }
    }

    func testBasicPromise() {
        let expectation = XCTestExpectation(description: "Test basic promise")

        let promise = Promise<Int> { resolve, _ in
            resolve(1)
        }

        promise.then { (num) in
            XCTAssertEqual(num, 1)
            expectation.fulfill()
        }.catch { _ in
            XCTFail()
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testCatching() {
        let expectation = XCTestExpectation(description: "Test catching")

        let promise = Promise<Bool> { _, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        promise.catch { _ in
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testCatchingBasic() {
        let expectation = XCTestExpectation(description: "Test catching basic")

        let promise = Promise<Bool> { _, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                reject(NSError(domain: "Error", code: -500, userInfo: [:]))
            })
        }

        promise.then { val in
            XCTFail()
            return
        }.catch { _ in
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

        work1("10").then { string in
            return work2(string)
        }.then { number in
            XCTFail()
            expectation.fulfill()
        }.catch { err in
            let err = err as NSError
            let message = err.domain
            XCTAssertEqual(message, "Error")
            expectation.fulfill()
        }

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

        work1("10").then(work2).then(work3).then { number in
            XCTAssertEqual(number, 100)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testMultiReject() {
        let expectation = XCTestExpectation(description: "Test multi reject promise")

        let error = NSError(domain: "Error", code: -500, userInfo: [:])

        let promise = Promise<Int> { (resolve, reject) in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                resolve(5)
            }

            DispatchQueue.global().async {
                reject(error)
            }
        }

        do {
            _ = try await(promise)
            XCTFail()
            expectation.fulfill()
        } catch (let e) {
            XCTAssertEqual(error.domain, (e as NSError).domain)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testMultiResolve() {
        let expectation = XCTestExpectation(description: "Test multi resolve promise")

        let error = NSError(domain: "Error", code: -500, userInfo: [:])

        let promise = Promise<Int> { (resolve, reject) in
            DispatchQueue.global().async {
                resolve(5)
            }

            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                reject(error)
            }
        }

        do {
            let response = try await(promise)
            XCTAssertEqual(response, 5)
            expectation.fulfill()
        } catch {
            XCTFail()
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testPending() {
        let promise = Promise<Any> { _, reject in
            reject(NSError(domain: "Error", code: -500, userInfo: [:]))
        }

        XCTAssertNil(promise.val)

        let promise2 = Promise<Int>()
        guard case .pending = promise2.state else {
            XCTFail()
            return
        }

        XCTAssertNil(promise2.val)
    }

    func testRejected() {
        let expectation = XCTestExpectation(description: "Test rejected promise")

        let error = NSError(domain: "Error", code: -500, userInfo: [:])
        let promise = Promise<Any>(error)
        promise.then { _ in
            XCTFail()
            expectation.fulfill()
        }.catch { (err) in
            XCTAssertEqual(error.domain, (err as NSError).domain)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testRejectedFunction() {
        let expectation = XCTestExpectation(description: "Test rejected promise function")

        let error = NSError(domain: "Error", code: -500, userInfo: [:])
        let promise = Promise<Any> {
            return error
        }

        promise.then { _ in
            XCTFail()
            expectation.fulfill()
        }.catch { (err) in
            XCTAssertEqual(error.domain, (err as NSError).domain)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testRejectOnQueue() {
        let expectation = XCTestExpectation(description: "Test rejected promise function on non-default queue")

        let error = NSError(domain: "Error", code: -500, userInfo: [:])
        let promise = Promise<Int>(dispatchQueue: .global()) { (_, reject) in
            reject(error)
        }

        do {
            _ = try await(promise)
            XCTFail()
        } catch (let e) {
            XCTAssertEqual(error.domain, (e as NSError).domain)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testResolved() {
        let expectation = XCTestExpectation(description: "Test resolved promise in all")

        let promise = Promise<Int>(15)

        let promise2 = Promise<Int> {
            return 25
        }

        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(10)
            })
        }

        all([promise, promise2, promise3]).then { (numbers) in
            let total = numbers.reduce(0, +)
            XCTAssertEqual(total, 50)
            expectation.fulfill()
        }.catch { _ in
            XCTFail()
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testResolveOnQueue() {
        let expectation = XCTestExpectation(description: "Test resolved promise function on non-default queue")

        let promise = Promise<Int>(dispatchQueue: .global()) { (resolve, _) in
            resolve(15)
        }

        do {
            let response = try await(promise)
            XCTAssertEqual(response, 15)
            expectation.fulfill()
        } catch {
            XCTFail()
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testSyntax() {
        let expectation = XCTestExpectation(description: "Test promise syntax")

        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                resolve(10)
            })
        }

        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(5)
            })
        }
        
        promise1.then { (val1) in
            promise2.then({ val2 in
                XCTAssertEqual(val1 + val2, 15)
                expectation.fulfill()
            })
        }

        self.wait(for: [expectation], timeout: 10)
    }
}
