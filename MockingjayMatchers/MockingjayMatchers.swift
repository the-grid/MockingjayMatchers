import Foundation
import Mockingjay

public func api(_ method: HTTPMethod, _ uri: String) -> (_ request: URLRequest) -> Bool {
    return { request in
        guard let headers = request.allHTTPHeaderFields,
            let accept = headers["Accept"],
            let acceptEncoding = headers["Accept-Encoding"],
            let contentType = headers["Content-Type"] ,
            accept == "application/json" &&
            contentType == "application/json" &&
            acceptEncoding == "gzip;q=1.0,compress;q=0.5"
        else {
            return false
        }
        
        return http(method, uri: uri)(request)
    }
}

public func api(_ method: HTTPMethod, _ uri: String, token: String) -> (_ request: URLRequest) -> Bool {
    return { request in
        guard let headers = request.allHTTPHeaderFields,
            let authorization = headers["Authorization"] ,
            authorization == "Bearer \(token)"
        else {
            return false
        }
        
        return api(method, uri)(request)
    }
}

public func api(_ method: HTTPMethod, _ uri: String, body: [String: AnyObject]) -> (_ request: URLRequest) -> Bool {
    return { request in
        // https://github.com/kylef/Mockingjay/issues/32
        guard let stream = request.httpBodyStream else {
            return false
        }
        
        stream.open()
        
        guard let streamJsonObject = try? JSONSerialization.jsonObject(with: stream, options: JSONSerialization.ReadingOptions()) else {
            return false
        }
        
        guard let streamDictionary = streamJsonObject as? [String: AnyObject] else {
            return false
        }
        
        let sortedStreamDictionary = sortDictionary(streamDictionary)
        let sortedBody = sortDictionary(body)
        
        let bodyStreamJsonData = try? JSONSerialization.data(withJSONObject: sortedStreamDictionary, options: JSONSerialization.WritingOptions())
        let bodyJsonData = try? JSONSerialization.data(withJSONObject: sortedBody, options: JSONSerialization.WritingOptions())

        guard bodyStreamJsonData == bodyJsonData else {
            return false
        }
        
        return api(method, uri)(request)
    }
}

public func api(_ method: HTTPMethod, _ uri: String, token: String, body: [String: AnyObject]) -> (_ request: URLRequest) -> Bool {
    return { request in
        return api(method, uri, token: token)(request) && api(method, uri, body: body)(request)
    }
}

private func sortDictionary(_ dictionary: [String: AnyObject]) -> [String: AnyObject] {
    return dictionary
        .sorted { $0.0 < $1.0 }
        .reduce([:]) { (accumulator, pair) in
            var acc = accumulator
            let (key, value) = pair
            let sortedValue: AnyObject
            
            if let value = value as? Array<[String: AnyObject]> {
                sortedValue = value.map(sortDictionary) as AnyObject
            } else if let value = value as? [String: AnyObject] {
                sortedValue = sortDictionary(value) as AnyObject
            } else {
                sortedValue = value
            }
            
            acc[key] = sortedValue
            return acc
        }
}
