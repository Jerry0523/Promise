import Promise
import PromiseSupport
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func mlog(_ msg: Any) -> Promise<Void> {
    print(msg)
    return Promise.post(())
}

func join(_ items: CustomStringConvertible...) -> Promise<String> {
    return Promise.post(items.reduce("", { $0 + $1.description }))
}

func parse(_ input: (data: Data?, response: URLResponse?)) -> Promise<[String: Any]> {
    return Promise<[String: Any]>(work: { resolve, reject in
        if let httpResponse = input.response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                reject(NSError(domain: "com.jerry.promise.demo", code: 0, userInfo: [NSLocalizedDescriptionKey: "unexpected response code \(httpResponse.statusCode)"]))
            }
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: input.data!, options: []) as? [String : Any] {
                resolve(json)
            } else {
                reject(NSError(domain: "com.jerry.promise.demo", code: 1, userInfo: [NSLocalizedDescriptionKey: "invalid response"]))
            }
        } catch {
            reject(error)
        }
    })
}

do {
    let promise = Promise<Int>()
    promise
        .then{ (1...$0).reduce(into: "", { $0 += "\($1)," }) }
        .then{ Promise.post($0.components(separatedBy: ",").dropLast(), delayed: 1000) }
        .then{ join("promise chaining ", $0, "\(Thread.isMainThread ? " in the main queue" : " in the global queue")") }
        .then(mlog)
        .detach(DispatchQueue.global())
    promise.resolve(3)
}

do {
    let promise0 = Promise.post(0, delayed: 1000)
    let promise1 = Promise<Int>()
    let promise2 = Promise.post(2)
    
    Promise<[Int]>
        .all([promise0, promise1, promise2])
        .detach(DispatchQueue.global())
        .then{ join("promise all ", $0, "\(Thread.isMainThread ? " in the main queue" : " in the global queue")") }
        .then(mlog)
        .catch{ print($0) }
    
    promise1.resolve(1)
}

do {
    let promise0 = Promise.post(2, delayed: 2000)
    let promise1 = Promise.post(3, delayed: 3000)
    
    Promise<Int>
        .race([promise0, promise1])
        .then{ join("promise race ", $0) }
        .then(mlog)
        .catch{ print($0) }
}

do {
    let (promise, dataTask) = URLSession.shared.dataTask(with: URL(string: "http://t.weather.sojson.com/api/weather/city/101020100".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!)
    dataTask.resume()
    
    promise
        .then(parse)
        .then(mlog)
        .catch{ print($0) }
}

do {
    Promise
        .post((), delayed: 5000)
        .then{ _ in PlaygroundPage.current.finishExecution() }
}
