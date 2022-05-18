//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Apple on 09/05/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    // Called every time before a test method executed
    override class func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    // Called every time after a test method executed
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // We can use same observeRequest behaviour for checking other methods
    // like POST or request body or query parameters of requests etc
    func test_getFromURL_performGETRequestFromURL() {
        let url = someURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")

        }
        makeSUT().get(from: url) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let expectedError = anyNSError()
        let error = resultErrorFor(data: nil, response: nil, error: expectedError) as NSError?
        
        if let receivedError = error {
            XCTAssertEqual(receivedError.domain, expectedError.domain)
            XCTAssertEqual(receivedError.code, expectedError.code)
        }
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValue = resultValueFor(data: anyData(), response: response, error: nil)

        XCTAssertEqual(receivedValue?.data, data)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let receivedValue = resultValueFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValue?.data, emptyData)
        XCTAssertEqual(receivedValue?.response.url, response.url)
        XCTAssertEqual(receivedValue?.response.statusCode, response.statusCode)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch receivedResult {
            case let .failure(error):
                return error
            default:
                XCTFail("Expected failure got \(receivedResult) instead", file: file, line: line)
                return nil
        }
    }

    private func resultValueFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let receivedResult = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch receivedResult {
            case let .success(data, response):
                return (data, response)
            default:
                XCTFail("Expected success got \(receivedResult) instead", file: file, line: line)
                return nil
        }
    }

    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
                
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: someURL()) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func someURL() -> URL {
        return URL(string: "https://some-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: someURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: someURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            URLProtocolStub.requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
