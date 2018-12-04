//
//  Promise.swift
//  Promise-Swift
//
//  Created by Jerry on 2018/9/7.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import Foundation

public final class Promise<T> {
    
    public init(work: (( (@escaping (T) -> ()), @escaping RejectHandler) -> Void)? = nil) {
        work?(self.resolve, self.reject)
    }
    
    public private(set) var state = State.pending {
        didSet {
           handleStateChange()
        }
    }
    
    @discardableResult
    public func then<O>(_ onResolved: @escaping (T) throws -> O) -> Promise<O> {
        return _then(onResolved, nil)
    }
    
    @discardableResult
    public func then<O>(_ onResolved: @escaping (T) throws -> O, _ onRejected: @escaping RejectHandler) -> Promise<O> {
        return _then(onResolved, onRejected)
    }
    
    @discardableResult
    public func then<O>(_ onResolved: @escaping (T) throws -> Promise<O>) -> Promise<O> {
        return _then(onResolved, nil)
    }
    
    @discardableResult
    public func then<O>(_ onResolved: @escaping (T) throws -> Promise<O>, _ onRejected: @escaping RejectHandler) -> Promise<O> {
        return _then(onResolved, onRejected)
    }
    
    @discardableResult
    public func detach(_ queue: DispatchQueue) -> Promise {
        operationQueue = queue
        return self
    }
    
    public func resolve(_ value: T) {
        ioQueue.async {
            guard case .pending = self.state else {
                return
            }
            self.state = .resolved(value: value)
        }
    }
    
    public func reject(_ reason: Error) {
        ioQueue.async {
            guard case .pending = self.state else {
                return
            }
            self.state = .rejected(reason: reason)
        }
    }
    
    internal var fulfilledHandlers = [(T) -> ()]()
    
    internal var rejectedHandlers = [RejectHandler]()
    
    internal var operationQueue: DispatchQueue?
    
    public enum State {
        
        case pending
        
        case resolved(value: T)
        
        case rejected(reason: Error)
        
        var isPendding: Bool {
            if case .pending = self {
                return true
            } else {
                return false
            }
        }
    }
}

extension Promise : Thenable {

    public typealias DataType = T
    
    public func connect(toNext next: AnyThenable) {
        ioQueue.async {
            self.fulfilledHandlers.append({ (val) in
                next.resolve(val)
            })
            self.rejectedHandlers.append({ (error) in
                next.reject(error)
            })
        }
    }
    
}

extension Promise {
    
    internal func handleStateChange() {
        ioQueue.async {
            switch self.state {
            case .resolved(let value):
                self.fulfilledHandlers.forEach({ (resolver) in
                    (self.operationQueue ?? defaultOperationQueue).sync {
                        resolver(value)
                    }
                })
                self.fulfilledHandlers.removeAll()
            case .rejected(let reason):
                self.rejectedHandlers.forEach({ (rejector) in
                    (self.operationQueue ?? defaultOperationQueue).sync {
                        rejector(reason)
                    }
                })
                self.rejectedHandlers.removeAll()
            default: break
            }
        }
    }
    
    internal func makeConnections<M, O>(_ onResolved: @escaping (T) throws -> M, _ onRejected: RejectHandler?, next: Promise<O>) {
        
        ioQueue.async {
            self.fulfilledHandlers.append { [unowned self] (val) in
                self.doResolve(onResolved, val: val, next: next)
            }
            
            self.rejectedHandlers.append { [unowned self] (error) in
                if let opQueue = self.operationQueue, next.operationQueue == nil {
                    next.detach(opQueue)
                }
                onRejected?(error)
                next.reject(error)
            }
        }
    }
    
    @discardableResult
    private func _then<O, R>(_ onResolved: @escaping (T) throws -> O, _ onRejected: RejectHandler?) -> Promise<R> {
        let ret = Promise<R>()
        makeConnections(onResolved, onRejected, next: ret)
        defer {
            handleStateChange()
        }
        return ret
    }
    
    private func doResolve<M, O>(_ onResolved: @escaping (T) throws -> M, val: T, next: Promise<O>) {
        do {
            if let opQueue = operationQueue, next.operationQueue == nil {
                next.detach(opQueue)
            }
            let mappedData = try onResolved(val)
            if let outputData = mappedData as? O {
                next.resolve(outputData)
            } else if let mappedSelf = mappedData as? Promise, mappedSelf === self {
                throw InternalError.invalidOutput(reason: "resolved value refer to promise itself")
            } else if let mappedThenable = mappedData as? AnyThenable {
                mappedThenable.connect(toNext: next)
            } else {
                throw InternalError.invalidOutput(reason: "unknown resolved value type \(mappedData)")
            }
        } catch {
            next.reject(error)
        }
    }
    
}

internal let ioQueue = DispatchQueue(label: "com.jerry.promise")

internal let defaultOperationQueue = DispatchQueue.main
