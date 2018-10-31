//
//  Extensions.swift
//  Promise
//
//  Created by Jerry on 2018/9/10.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import Foundation

extension Promise {
    
    public static func post(_ callback: @autoclosure @escaping () -> T, delayed millisecond: UInt = 0) -> Promise {
        let ret = Promise()
        defer {
            if millisecond != 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(millisecond) / 1000.0, execute: {
                    ret.resolve(callback())
                })
            } else {
                ret.resolve(callback())
            }
        }
        return ret
    }
    
}

extension Promise {
    
    public func `catch`(_ onRejected: @escaping (Error) ->()) {
        ioQueue.async {
            self.rejectedHandlers.append { (error) in
                onRejected(error)
            }
        }
        handleStateChange()
    }
    
    public func `catch`<E>(_ onRejected: @escaping (E) ->()) -> Self where E: Error {
        ioQueue.async {
            self.rejectedHandlers.append { (error) in
                if let errVal = error as? E {
                    onRejected(errVal)
                }
            }
        }
        handleStateChange()
        return self
    }
    
}
