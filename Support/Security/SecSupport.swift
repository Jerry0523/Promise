//
//  SecSupport.swift
//  Promise
//
//  Created by 王杰 on 2018/10/26.
//  Copyright © 2018 com.jerry. All rights reserved.
//

import Foundation
import Promise
import Security

public typealias SecDictionaryType = [String: Any]

public func SecItemUpdate(_ query: SecDictionaryType, _ attributesToUpdate: SecDictionaryType) -> Promise<(query: SecDictionaryType, update: SecDictionaryType)> {
    return Promise<(query: SecDictionaryType, update: SecDictionaryType)>(work: { (resolve, reject) in
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if status == noErr {
            resolve((query: query, update: attributesToUpdate))
        } else {
            reject(error(forOSStatus: status))
        }
    })
}

public func SecItemCopyMatching(_ query: SecDictionaryType) -> Promise<AnyObject?> {
    return Promise<AnyObject?>(work: { (resolve, reject) in
        let result = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let status = SecItemCopyMatching(query as CFDictionary, result)
        if status == noErr {
            resolve(result.pointee)
            result.deallocate()
        } else {
            reject(error(forOSStatus: status))
        }
    })
}

public func SecItemAdd(_ attributes: SecDictionaryType) -> Promise<AnyObject?> {
    return Promise<AnyObject?>(work: { (resolve, reject) in
        let result = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
        let status = SecItemAdd(attributes as CFDictionary, result)
        if status == noErr {
            resolve(result.pointee)
            result.deallocate()
        } else {
            reject(error(forOSStatus: status))
        }
    })
}

public func SecItemDelete(_ query: SecDictionaryType) -> Promise<SecDictionaryType> {
    return Promise<SecDictionaryType>(work: { (resolve, reject) in
        let status = SecItemDelete(query as CFDictionary)
        if status == noErr {
            resolve(query)
        } else {
            reject(error(forOSStatus: status))
        }
    })
}

private func error(forOSStatus status: OSStatus) -> Error {
    return NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
}
