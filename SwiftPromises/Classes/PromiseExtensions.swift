//
//  PromiseExtensions.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public func all<Value>(_ promises: [Promise<Value>], timeout: Int = 15) -> Promise<[Value]> {
    return Promise<[Value]> { resolve, reject in
        var results: [Value] = []
        let dispatchGroup = DispatchGroup()

        for promise in promises {
            dispatchGroup.enter()
            promise.then { val in
                    results.append(val)
                    dispatchGroup.leave()
                }.catch { err in
                    reject(err)
                }
        }

        promiseQueue.asyncAfter(deadline: .now() + .seconds(timeout), execute: {
            reject(NSError(domain: "Timeout", code: -1, userInfo: [:]))
        })

        dispatchGroup.notify(queue: promiseQueue) {
            resolve(results)
        }
    }
}
