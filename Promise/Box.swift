//
//  Box.swift
//  Promise
//
//  Created by Jerry on 2018/12/6.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import Foundation

public struct Box {
    
    private let value: Any
    
    public init(_ val: Any) {
        value = val
    }
    
    public func fetch<T>() -> T? {
        return value as? T
    }
}

extension Array where Element == Box {
    
    public func unpack2<A, B>() throws -> (A, B) {
        if self.count != 2 {
            throw InternalError.invalidInput(reason: "invalid item count")
        }
        let a: A? = self[0].fetch()
        let b: B? = self[1].fetch()
        
        guard let ma = a, let mb = b else {
            throw InternalError.invalidOutput(reason: "empty ret type")
        }
        
        return (ma, mb)
    }
    
    public func unpack3<A, B, C>() throws -> (A, B, C) {
        if self.count != 3 {
            throw InternalError.invalidInput(reason: "invalid item count")
        }
        let a: A? = self[0].fetch()
        let b: B? = self[1].fetch()
        let c: C? = self[2].fetch()
        
        guard let ma = a, let mb = b, let mc = c else {
            throw InternalError.invalidOutput(reason: "empty ret type")
        }
        
        return (ma, mb, mc)
    }
    
    public func unpack4<A, B, C, D>() throws -> (A, B, C, D) {
        if self.count != 4 {
            throw InternalError.invalidInput(reason: "invalid item count")
        }
        let a: A? = self[0].fetch()
        let b: B? = self[1].fetch()
        let c: C? = self[2].fetch()
        let d: D? = self[3].fetch()
        
        guard let ma = a, let mb = b, let mc = c, let md = d else {
            throw InternalError.invalidOutput(reason: "empty ret type")
        }
        
        return (ma, mb, mc, md)
    }
    
    public func unpack5<A, B, C, D, E>() throws -> (A, B, C, D, E) {
        if self.count != 5 {
            throw InternalError.invalidInput(reason: "invalid item count")
        }
        let a: A? = self[0].fetch()
        let b: B? = self[1].fetch()
        let c: C? = self[2].fetch()
        let d: D? = self[3].fetch()
        let e: E? = self[4].fetch()
        
        guard let ma = a, let mb = b, let mc = c, let md = d, let me = e else {
            throw InternalError.invalidOutput(reason: "empty ret type")
        }
        
        return (ma, mb, mc, md, me)
    }
}

extension Promise {
    
    public func pack() -> Promise<Box> {
        return then(Box.init)
    }
    
}
