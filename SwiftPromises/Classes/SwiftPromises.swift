//
//  SwiftPromises.swift
//  SwiftPromises
//
//  Created by Wyatt Mufson on 6/16/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import Foundation

public final class Promise<Value> {

    private enum State<T> {
        case pending
        case resolved(T)
        case rejected(Error)
    }

    private var state: State<Value> = .pending
    private var callback: ((Value) -> Void)? = nil
    private var errorCallback: ((Error) -> Void)? = nil
    private var dispatchQueue: DispatchQueue = .global()

    public init(dispatchQueue: DispatchQueue = .global(), executor: (_ resolve: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
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
                onResolved(value).then(resolve).catch(reject)
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
        if updateState(to: .rejected(error)) {
            guard let errorCallback = errorCallback else { return }
            dispatchQueue.async {
                errorCallback(error)
            }
        }
    }

    private func resolve(value: Value) {
        if updateState(to: .resolved(value)) {
            guard let callback = callback else { return }
            dispatchQueue.async {
                callback(value)
            }
        }
    }

    private func updateState(to newState: State<Value>) -> Bool {
        guard case .pending = state else { return false }
        state = newState
        return true
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
