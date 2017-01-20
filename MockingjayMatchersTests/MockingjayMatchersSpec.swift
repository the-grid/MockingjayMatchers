import Mockingjay
import MockingjayMatchers
import Nimble
import Quick

private func setHTTPHeadersForRequest(_ request: NSMutableURLRequest) {
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("gzip;q=1.0,compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
}

private func setAuthorizationHeaderForRequest(_ request: NSMutableURLRequest, token: String) {
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}

private func setHTTPBodyStreamForRequest(_ request: NSMutableURLRequest, body: [String: AnyObject]) {
    let data = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
    request.httpBodyStream = InputStream.init(data: data)
}

class MockingjayMatchersSpec: QuickSpec {
    override func spec() {
        describe("HTTP header matcher") {
            it("should match the correct HTTP headers") {
                let method: HTTPMethod = .get
                let url = "https://example.com/api"
                
                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                request.httpMethod = method.description
                
                let matcher = api(method, url)
                
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request as URLRequest)).to(equal(true))
            }
        }
        
        describe("HTTP Authorization header matcher") {
            it("should match the correct HTTP Authorization header") {
                let method: HTTPMethod = .get
                let url = "https://example.com/api"
                let token = "token"
                
                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                request.httpMethod = method.description
                
                let matcher = api(method, url, token: token)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setAuthorizationHeaderForRequest(request, token: token)
                expect(matcher(request as URLRequest)).to(equal(true))
            }
        }
        
        describe("HTTP body matcher") {
            it("should match the correct HTTP body") {
                let method: HTTPMethod = .get
                let url = "https://example.com/api"
                let body: [String: AnyObject] = [ "key": "value" as AnyObject ]
                
                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                request.httpMethod = method.description
                
                let matcher = api(method, url, body: body)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request as URLRequest)).to(equal(true))
            }
        }
        
        describe("HTTP Authorization header and HTTP Body matcher") {
            it("should match the correct HTTP Authorization header and HTTP body") {
                let method: HTTPMethod = .get
                let url = "https://example.com/api"
                let token = "token"
                let body: [String: AnyObject] = [ "key": "value" as AnyObject ]

                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
                request.httpMethod = method.description
                
                let matcher = api(.get, url, token: token, body: body)
                
                setHTTPHeadersForRequest(request)
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setAuthorizationHeaderForRequest(request, token: token)
                request.httpBodyStream = .none
                expect(matcher(request as URLRequest)).to(equal(false))
                
                setHTTPBodyStreamForRequest(request, body: body)
                expect(matcher(request as URLRequest)).to(equal(true))
            }
        }
    }
}
