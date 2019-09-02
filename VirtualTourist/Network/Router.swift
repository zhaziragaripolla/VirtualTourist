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
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

class Router<EndPoint: EndpointType>: NetworkRouter {
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
//            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        
        var request = URLRequest(url: route.baseUrl.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.method.rawValue
        setQueryParameters(queryParameters: route.task, request: &request)
//        switch route.task {
//        case .request:
//            break
//        case .requestParameters(let queryParameters):
//            setQueryParameters(queryParameters: queryParameters, request: &request)
//        }
        print(request.url)
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
    
//    fileprivate func setPathComponents(pathComponents: [String], request: inout URLRequest) {
//        // TODO: fix
//
//        pathComponents.forEach( {
//            request.url?.appendingPathComponent($0)
//        })
//    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

