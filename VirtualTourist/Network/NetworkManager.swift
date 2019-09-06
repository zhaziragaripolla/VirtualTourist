//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit

enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    case connectionFailed = "Please check your internet connection"
}

enum Result<String>{
    case success
    case failure(String)
}

class NetworkManager {
    private let router = Router<FlickrApi>()
    
    public func searchPhotos(page: Int, lat: Float, long: Float, completion: @escaping (_ photos: PhotoResponse?, _ error: String?)-> ()){
        let request = router.buildRequest(from: .search(long: long, lat: lat, page: page))
        router.makeRequest(request) { data, response, error in
            if error != nil {
                completion(nil, NetworkResponse.connectionFailed.rawValue)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let decodedData = try JSONDecoder().decode(SearchResponse.self, from: responseData)
                        completion(decodedData.photos, nil)

                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    public func getImage(photo: FlickrPhoto, completion: @escaping (Data?)->()) {
        let request = router.buildRequest(from: .getImage(photo: photo))
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: request.url!)
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
     fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
