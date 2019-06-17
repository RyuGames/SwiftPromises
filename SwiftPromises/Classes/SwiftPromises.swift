//
//  SwiftPromises.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public let promiseQueue: DispatchQueue = .global()

public final class Promise<Value> {

    internal enum State<T> {
        case pending
        case resolved(T)
        case rejected(Error)
    }

    internal var state: State<Value> = .pending
    internal var val: Value? {
        if case let .resolved(value) = state {
            return value
        }
        return nil
    }

    private var callback: ((Value) -> Void)? = nil
    private var errorCallback: ((Error) -> Void)? = nil
    private var dispatchQueue: DispatchQueue = promiseQueue

    public init(dispatchQueue: DispatchQueue = promiseQueue, executor: (_ resolve: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
        self.dispatchQueue = dispatchQueue
        executor(resolve, reject)
    }

    public func then(_ onResolved: @escaping (Value) -> Void) {
        callback = onResolved
        triggerCallbacksIfResolved()
    }

    public func then<NewValue>(_ onResolved: @escaping (Value) -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { resolve, reject in
            then { value in
                onResolved(value).then(resolve)
            }
        }
    }

    public func then<NewValue>(_ onResolved: @escaping (Value) -> NewValue) -> Promise<NewValue> {
        return then { value in
            return Promise<NewValue> { resolve, _ in
                resolve(onResolved(value))
            }
        }
    }

    public func `catch`(_ onRejected: @escaping (Error) -> Void) {
        errorCallback = onRejected
        triggerErrorCallbacksIfRejected()
    }

    private func reject(error: Error) {
        updateState(to: .rejected(error))
        triggerErrorCallbacksIfRejected()
    }

    private func resolve(value: Value) {
        updateState(to: .resolved(value))
        triggerCallbacksIfResolved()
    }

    private func updateState(to newState: State<Value>) {
        guard case .pending = state else { return }
        state = newState
    }

    private func triggerCallbacksIfResolved() {
        guard case let .resolved(value) = state else { return }
        guard let callback = callback else { return }
        dispatchQueue.async {
            callback(value)
        }
    }

    private func triggerErrorCallbacksIfRejected() {
        guard case let .rejected(error) = state else { return }
        guard let errorCallback = errorCallback else { return }
        dispatchQueue.async {
            errorCallback(error)
        }
    }
}
