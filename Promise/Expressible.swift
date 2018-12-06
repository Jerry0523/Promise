//
//  Expressible.swift
//  Promise
//
//  Created by 王杰 on 2018/12/5.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import Foundation

extension Promise : ExpressibleByIntegerLiteral where T == Int {
    
    public typealias IntegerLiteralType = Int
    
    public convenience init(integerLiteral value: IntegerLiteralType) {
        self.init { (resolve, reject) in
            resolve(value)
        }
    }
    
}

extension Promise: ExpressibleByUnicodeScalarLiteral where T == String {
    
    public typealias UnicodeScalarLiteralType = String
    
    public convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init { (resolve, reject) in
            resolve(value)
        }
    }
    
}

extension Promise: ExpressibleByExtendedGraphemeClusterLiteral where T == String {
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init { (resolve, reject) in
            resolve(value)
        }
    }
    
}

extension Promise : ExpressibleByStringLiteral where T == String {

    public typealias StringLiteralType = String
    
    public convenience init(stringLiteral value: StringLiteralType) {
        self.init { (resolve, reject) in
            resolve(value)
        }
    }

}
