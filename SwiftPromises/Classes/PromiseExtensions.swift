//
//  PromiseExtensions.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

/// Calls an array of Promises in parallel
/// Returns a new Promise with an array of the resolved values.
/// If one of the Promises in the array throws an error, the catch function is called.
/// - Parameter promises: The array of Promises to execute.
/// - Parameter timeout: The amount of milliseconds to pass before triggering a timeout error.
public func all<Value>(dispatchQueue: DispatchQueue? = nil, _ promises: [Promise<Value>], timeout: Int = 15000) -> Promise<[Value]> {
    return Promise<[Value]>(dispatchQueue: dispatchQueue) { resolve, reject in
        if promises.count == 0 {
            resolve([])
            return
        }

        var resolved: Bool = false
        for promise in promises {
            promise.then { _ in
                var done = true
                for p in promises {
                    if case .pending = p.state {
                        done = false
                    }
                }

                if done && !resolved {
                    resolved = true
                    resolve(promises.map { $0.val! })
                }
            }.catch { err in
                if !resolved {
                    resolved = true
                    reject(err)
                }
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeout), execute: {
            if !resolved {
                resolved = true
                reject(NSError(domain: "Timeout", code: -1, userInfo: [:]))
            }
        })
    }
}

/// Synchronously calls a Promise
/// Halts the given thread until it has completed.
/// - Parameter dispatchQueue: The `DispatchQueue` to run the given Promise on.
/// Defaults to `.global(qos: .background)`
/// - Parameter promise: The Promise to execute.
public func await<Value>(dispatchQueue: DispatchQueue = .global(qos: .background), _ promise: Promise<Value>) throws -> Value {
    var result: Value!
    var error: Error?

    let semaphore = DispatchSemaphore(value: 0)

    dispatchQueue.async {
        promise.then { (value) in
            result = value
            semaphore.signal()
        }.catch { (err) in
            error = err
            semaphore.signal()
        }
    }

    _ = semaphore.wait(wallTimeout: .distantFuture)
    if let error = error {
        throw error
    }

    return result
}
