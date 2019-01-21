//
//  Thenable.swift
//  Promise
//
//  Created by Jerry on 2018/10/6.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

public protocol AnyThenable {
    
    func resolve(_ value: Any)
    
    func reject(_ reason: Error)
    
    func connect(toNext: AnyThenable)
    
}

public protocol Thenable : AnyThenable {
    
    associatedtype DataType
    
    func resolve(_ value: DataType)
    
}

extension Thenable {
    
    public func resolve(_ value: Any) {
        guard value is DataType else {
            reject(InternalError.invalidInput(reason: "unsupported input type \(value)"))
            return
        }
        resolve(value as! DataType)
    }
}

public enum InternalError : Error, CustomStringConvertible {
    
    case invalidInput(reason: String)
    
    case invalidOutput(reason: String)
    
    public var description: String {
        switch self {
        case .invalidInput(let reason):
            return "InternalError.invalidInput: " + reason
        case .invalidOutput(let reason):
            return "InternalError.invalidOutput: " + reason
        }
    }
    
}
