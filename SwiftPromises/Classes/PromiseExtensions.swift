//
//  PromiseExtensions.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public func all<Value>(_ promises: [Promise<Value>]) -> Promise<[Value]> {
    return Promise<[Value]> { resolve, reject in
        var results: [Value] = []
        var count = 0
        let length = promises.count
        for promise in promises {
            promise
                .then { val in
                    results.append(val)
                    count += 1
                    if count == length {
                        resolve(results)
                    }
                }
                .catch { err in
                    reject(err)
            }
        }
    }
}
