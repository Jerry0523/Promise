//
//  Operations.swift
//  Promise
//
//  Created by Jerry on 2018/10/10.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import Foundation

extension Promise {
    
    public static func race<T>(_ inputs: [Promise<T>]) -> Promise<T> {
        let ret = Promise<T>()
        if inputs.count > 0 {
            var failedCount = 0
            inputs.enumerated().forEach { (_, element) in
                element.then({ (val) -> Void in
                    ioQueue.async {
                        if !ret.state.isPending {
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
                }, nil)
            }
        } else {
            ret.reject(InternalError.invalidInput(reason: "empty input for operation: race"))
        }
        return ret
    }
    
    public static func all<T>(_ inputs: [Promise<T>]) -> Promise<[T]> {
        let ret = Promise<[T]>()
        if inputs.count > 0 {
            var vals = [Int: T]()
            inputs.enumerated().forEach { (offset, element) in
                element.then({ (val) -> Void in
                    ioQueue.async {
                        if !ret.state.isPending {
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
                }, nil)
            }
        } else {
            ret.reject(InternalError.invalidInput(reason: "empty input for operation: all"))
        }
        return ret
    }
    
}
