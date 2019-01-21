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
    
    public typealias ProgressHandler = (Double) -> ()
    
    public func progress(_ val: Double) {
        ioQueue.async {
            guard case .pending = self.state else {
                return
            }
            self.progressHandlers.forEach({ (progresser) in
                (self.operationQueue ?? mDefaultOperationQueue).sync {
                    progresser(val)
                }
            })
        }
    }
    
}

extension Promise {
    
    public func `catch`(_ onRejected: @escaping (Error) ->()) {
        _ = _catch(onRejected, filter: { _ in true })
    }
    
    public func `catch`<E>(_ onRejected: @escaping (E) ->()) -> Self where E: Error {
        return _catch({ onRejected($0 as! E) }, filter: { $0 is E })
    }
    
    private func `_catch`(_ onRejected: @escaping (Error) ->(), filter: @escaping (Error) -> Bool ) -> Self {
        ioQueue.async {
            self.rejectedHandlers.append { (error) in
                if filter(error) {
                    onRejected(error)
                }
            }
        }
        handleStateChange()
        return self
    }
    
}
