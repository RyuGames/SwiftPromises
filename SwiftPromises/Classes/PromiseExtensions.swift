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
        if promises.count == 0 {
            resolve([])
            return
        }

        var resolved: Bool = false
        for promise in promises {
            promise.then ({ _ in
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
            }).catch ({ err in
                if !resolved {
                    resolved = true
                    reject(err)
                }
            })
        }

        promiseQueue.asyncAfter(deadline: .now() + .seconds(timeout), execute: {
            if !resolved {
                resolved = true
                reject(NSError(domain: "Timeout", code: -1, userInfo: [:]))
            }
        })
    }
}
