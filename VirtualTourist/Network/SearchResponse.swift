//
//  SearchResponse.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/2/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import Foundation


struct SearchResponse: Codable {
    let photos: PhotoResponse?
    let stat: String
}

struct PhotoResponse: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}

