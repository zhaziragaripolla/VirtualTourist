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
    var task: HTTPQueryParameters? {get}
}

public enum FlickrMethod: String {
    case search = "flickr.photos.search"
}

enum FlickrApi {
    case search(long: Float, lat: Float, page: Int)
    case getImage(photo: FlickrPhoto)
}

extension FlickrApi: EndpointType {
    var task: HTTPQueryParameters? {
        switch self {
        case .search(let long, let lat, let page):
            return ["method": FlickrMethod.search.rawValue,
                    "api_key": APIKey.apiKey,
                    "bbox" : "\(long - 1),\(lat - 1),\(long + 1),\(lat + 1)",
                    "format" : "json",
                    "nojsoncallback" : "1",
                    "page" : "\(page)",
                    "per_page" : "50"
            ]
        case .getImage:
            return nil
        }
    }
    
    var baseUrl: URL {
        switch self {
        case .search:
            return URL(string: "https://api.flickr.com/services/rest/")!
        case .getImage(let photo):
            return URL(string: "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_m.jpg")!
        }
        
    }

    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        switch self {
        case .search:
            return .GET
        case .getImage:
            return .GET
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
