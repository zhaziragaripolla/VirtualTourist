//
//  NetworkService.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//


import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public typealias HTTPHeaders = [String:String]
public typealias HTTPBodyParameters = [String: Any]
public typealias HTTPQueryParameters = [String: String]

protocol EndpointType {
    var baseUrl: URL {get}
    var path: String {get}
    var method: HTTPMethod {get}
    var headers: HTTPHeaders? {get}
    var task: HTTPQueryParameters {get}
}

class NetworkService {
    
}

public enum FlickrMethod: String {
    case search = "flickr.photos.search"
}

public enum FlickrApi {
    case search(lat: Float, long: Float, page: Int)
}

extension FlickrApi: EndpointType {
    var task: HTTPQueryParameters {
        switch self {
        case .search(let lat, let long, let page):
            return ["method": FlickrMethod.search.rawValue,
                    "api_key": APIKey.apiKey,
                    "bbox" : "\(55),\(8),\(58),\(13)",
                    "format" : "json",
                    "nojsoncallback" : "1"
            ]
        }
    }
    
    var baseUrl: URL {
        return URL(string: "https://api.flickr.com/services/rest/")!
    }

    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        switch self {
        case .search:
            return .GET
        default:
            break
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
