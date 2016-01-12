import Mockingjay
import MockingjayMatchers
import Nimble
import Quick

private func setHTTPHeadersForRequest(request: NSMutableURLRequest) {
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
}

private func setAuthorizationHeaderForRequest(request: NSMutableURLRequest, token: String) {
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}

private func setHTTPBodyStreamForRequest(request: NSMutableURLRequest, body: [String: AnyObject]) {
    let data = try! NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
    request.HTTPBodyStream = NSInputStream.init(data: data)
}

class MockingjayMatchersSpec: QuickSpec {
    override func spec() {
        describe("HTTP header matcher") {
            it("should match the correct HTTP headers") {
                let method: HTTPMethod = .GET
                let url = "https://example.com/api"
                
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = method.description
                
                let matcher = api(method, url)
                
                expect(matcher(request: request)).to(equal(false))
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request: request)).to(equal(true))
            }
        }
        
        describe("HTTP Authorization header matcher") {
            it("should match the correct HTTP Authorization header") {
                let method: HTTPMethod = .GET
                let url = "https://example.com/api"
                let token = "token"
                
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = method.description
                
                let matcher = api(method, url, token: token)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request: request)).to(equal(false))
                
                setAuthorizationHeaderForRequest(request, token: token)
                expect(matcher(request: request)).to(equal(true))
            }
        }
        
        describe("HTTP body matcher") {
            it("should match the correct HTTP body") {
                let method: HTTPMethod = .GET
                let url = "https://example.com/api"
                let body: [String: AnyObject] = [ "key": "value" ]
                
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = method.description
                
                let matcher = api(method, url, body: body)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request: request)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request: request)).to(equal(true))
            }
        }
        
        describe("HTTP Authorization header and HTTP Body matcher") {
            it("should match the correct HTTP Authorization header and HTTP body") {
                let method: HTTPMethod = .GET
                let url = "https://example.com/api"
                let token = "token"
                let body: [String: AnyObject] = [ "key": "value" ]
                
                let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                request.HTTPMethod = method.description
                
                let matcher = api(.GET, url, token: token, body: body)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request: request)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request: request)).to(equal(false))
                
                setAuthorizationHeaderForRequest(request, token: token)
                request.HTTPBodyStream = .None
                expect(matcher(request: request)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request: request)).to(equal(true))
            }
        }
    }
}
