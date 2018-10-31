//
//  Operations.swift
//  Promise
//
//  Created by Jerry on 2018/10/10.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import Foundation

public struct Box {
    
    public let value: Any
    
    public init(_ val: Any) {
        value = val
    }
}

extension Promise {
    
    public func asBox() -> Promise<Box> {
        return then({ Box($0) })
    }
    
    public static func race<T>(_ inputs: [Promise<T>]) -> Promise<T> {
        let ret = Promise<T>()
        var failedCount = 0
        
        inputs.enumerated().forEach { (_, element) in
            element.then({ (val) -> Void in
                ioQueue.async {
                    if !ret.state.isPendding {
                        return
                    }
                    ret.resolve(val)
                }
            }, { (error) in
                ioQueue.async {
                    failedCount += 1
                    if failedCount == inputs.count {
                        ret.reject(error)
                    }
                }
            })
        }
        return ret
    }
    
    public static func all<T>(_ inputs: [Promise<T>]) -> Promise<[T]> {
        let ret = Promise<[T]>()
        var vals = [Int: T]()
        inputs.enumerated().forEach { (offset, element) in
            element.then({ (val) -> Void in
                ioQueue.async {
                    if !ret.state.isPendding {
                        return
                    }
                    vals[offset] = val
                    if vals.count == inputs.count {
                        var retVal = [T]()
                        (0..<inputs.count).forEach{ retVal.append(vals[$0]!) }
                        ret.resolve(retVal)
                    }
                }
            }, { (error) in
                ioQueue.async {
                    ret.reject(error)
                }
            })
        }
        return ret
    }
    
}