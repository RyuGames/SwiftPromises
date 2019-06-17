//
//  SwiftPromises.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

/// The default queue to run the Promises on
public let promiseQueue: DispatchQueue = .global()

/// A Promise is an object representing the eventual completion/failure of an asynchronous operation.
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

    /// A `Then` block.
    public typealias Then = (Value) -> Void

    /// A `Catch` block.
    public typealias Catch = (Error) -> Void

    private var callback: Then? = nil
    private var errorCallback: Catch? = nil
    private var dispatchQueue: DispatchQueue = promiseQueue

    /// Initailizes a new Promise
    /// - Parameter dispatchQueue: The `DispatchQueue` to run the given Promise on.
    /// Defaults to `promiseQueue`.
    /// - Parameter executor: The `Then` and `Catch` blocks.
    /// - Parameter resolve: The `Then` block
    /// - Parameter reject: The `Catch` block
    public init(dispatchQueue: DispatchQueue = promiseQueue, executor: (_ resolve: @escaping Then, _ reject: @escaping Catch) -> Void) {
        self.dispatchQueue = dispatchQueue
        executor(resolve, reject)
    }

    /// Handles resolving the Promise.
    /// - Parameter onResolved: The `Then` block
    /// - Parameter onRejected: The `Catch` block
    public func then(_ onResolved: @escaping Then, _ onRejected: @escaping Catch = { _ in }) {
        callback = onResolved
        triggerCallbacksIfResolved()
        errorCallback = onRejected
        triggerErrorCallbacksIfRejected()
    }

    /// Handles resolving the Promise (flatMap).
    /// - Parameter onResolved: Block to execute when resolved.
    public func then<NewValue>(_ onResolved: @escaping (Value) -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { resolve, reject in
            then({ (value) in
                onResolved(value).then(resolve).catch(reject)
            })
        }
    }

    /// Handles resolving the Promise (map).
    /// - Parameter onResolved: Block to execute when resolved.
    public func then<NewValue>(_ onResolved: @escaping (Value) -> NewValue) -> Promise<NewValue> {
        return Promise<NewValue> { resolve, reject in
            return then({ (val) in
                resolve(onResolved(val))
            }, { (error) in
                reject(error)
            })
        }
    }

    /// The error callback for the given Promise
    /// - Parameter onRejected: The `Catch` block
    public func `catch`(_ onRejected: @escaping Catch) {
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
