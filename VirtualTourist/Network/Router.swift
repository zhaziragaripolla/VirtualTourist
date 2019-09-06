//
//  Router.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndpointType
    func makeRequest(_ request: URLRequest, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

class Router<EndPoint: EndpointType>: NetworkRouter {
 
    private var task: URLSessionTask?

    public func makeRequest(_ request: URLRequest, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        
        task = session.dataTask(with: request, completionHandler: { data, response, error in
            completion(data, response, error)
        })
        self.task?.resume()
    }
    
    public func cancel() {
        self.task?.cancel()
    }
    
    public func buildRequest(from route: EndPoint)-> URLRequest {
        
        var request = URLRequest(url: route.baseUrl.appendingPathComponent(route.path))
        request.httpMethod = route.method.rawValue
        setQueryParameters(queryParameters: route.task, request: &request)
        return request
    }
    
    fileprivate func setQueryParameters(queryParameters: HTTPQueryParameters?,
                                         request: inout URLRequest) {
        guard
            let unwrappedQueryParameters = queryParameters,
            var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            else {
                return
        }
        
        urlComponents.queryItems = unwrappedQueryParameters.compactMap({ (value) -> URLQueryItem? in
            return URLQueryItem(name: value.key, value: value.value)
        })
        
        if let unwrappedURL = urlComponents.url {
            request.url = unwrappedURL
        }
    }

    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

