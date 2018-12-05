//
//  URLSession+Promise.swift
//  Promise
//
//  Created by Jerry on 2018/9/18.
//  Copyright © 2018年 com.jerry. All rights reserved.
//

import Foundation
import Promise

public extension URLSession {
    
    public func dataTask(with request: URLRequest) -> (promise: Promise<(Data?, URLResponse?)>, dataTask: URLSessionDataTask) {
        var dataTask: URLSessionDataTask?
        let promise = Promise<(Data?, URLResponse?)>(work: { (resolve, reject) in
            dataTask = self.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    reject(error!)
                } else {
                    resolve((data, response))
                }
            })
        })
        return (promise, dataTask!)
    }
    
    public func dataTask(with url: URL) -> (promise: Promise<(Data?, URLResponse?)>, dataTask: URLSessionDataTask) {
        var dataTask: URLSessionDataTask?
        let promise = Promise<(Data?, URLResponse?)>(work: { (resolve, reject) in
            dataTask = self.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    reject(error!)
                } else {
                    resolve((data, response))
                }
            })
        })
        return (promise, dataTask!)
    }
}
