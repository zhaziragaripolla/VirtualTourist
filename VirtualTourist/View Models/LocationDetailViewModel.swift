//
//  LocationDetailViewModel.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/3/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import Foundation

protocol LocationDetailViewModelProtocol: class {
    func foundPhotos(photos: [Photo])
    func showAlert(message: String)
}

class LocationDetailViewModel {
    
    public var currentPin: Pin!
    public var dataManager: DataManager!
    private var currentPage: Int = 1
    
    let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
    init() {
        
    }
    
    func searchPhotos(){
        networkManager.searchPhotos(page: currentPage, lat: currentPin.latitude, long: currentPin.longitude, completion: {[weak self] photos in
            guard let photos = photos else {
                print("No photos")
                return
            }
            self?.delegate?.foundPhotos(photos: photos)
        })
    }
    
    func downloadImages() {
        
    }
    
}
