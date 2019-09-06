//
//  LocationDetailViewModel.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/3/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit

protocol LocationDetailViewModelProtocol: class {
    func showAlert(message: String)
    func reloadRows()
}

class LocationDetailViewModel {
    
    public var currentPin: Pin!
    public var dataManager: DataManager!
    public var isUsingSavedPhotos: Bool
    
    private var currentPage: Int
    private var totalPages: Int
    
    public var flickrPhotos: [FlickrPhoto] = []
    public var savedPhotos: [Photo] = []
    private var images: [UIImage] = []
    
    private let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
    init() {
        totalPages = 1
        isUsingSavedPhotos = false
        currentPage = 1
    }
    
    public func loadSavedPhotos() {
        if let photoSet = currentPin.photo, let photos = photoSet.allObjects as? [Photo], photos.count > 0 {
            savedPhotos = photos
            print("Found \(photos.count) saved photos associated with pin")
            isUsingSavedPhotos = true
            delegate?.reloadRows()
        }
        else {
            print("Loading photos from Flickr API")
            isUsingSavedPhotos = false
            searchPhotos()
        }
        
    }
    
    func downloadNewData(){
        if isUsingSavedPhotos {
            
        }
        else {
            
        }
    }
    
    func searchPhotos(){
        images.removeAll()
        flickrPhotos.removeAll()
        networkManager.searchPhotos(page: currentPage, lat: currentPin.latitude, long: currentPin.longitude, completion: {[weak self] response in
            guard let response = response else {
                print("No photos")
                return
            }
            self?.totalPages = response.pages
            self?.flickrPhotos = response.photo
            self?.currentPage = Int.random(in: 1...self!.totalPages)
            print("Random current page is ",  self?.currentPage, "/\(self?.totalPages)")
            self?.delegate?.reloadRows()
            
        })
        
    }
    
    func downloadImage(for photo: FlickrPhoto, completion: @escaping (UIImage?)-> Void) {
//        sleep(3)
        networkManager.getImage(photo: photo, completion: { data in
            if let unwrappedData = data, let image = UIImage(data: unwrappedData) {
                self.images.append(image)
                completion(image)
            }
        })
        
    }
    
    
    func savePhotos(){
        images.forEach({
            self.dataManager.savePhoto(with: currentPin, attributes: ["image" : $0.pngData()])
        })
    }
    
    public  func deleteImages(at indices: [Int]) {
        if isUsingSavedPhotos {
            for index in 0..<indices.count {
                self.dataManager.deleteEntity(entity: self.savedPhotos[index])
                self.savedPhotos.remove(at: index)
            }
                delegate?.reloadRows()
        }

        else {
            for index in 0..<indices.count {
                flickrPhotos.remove(at: index)
                images.remove(at: index)
            }
            delegate?.reloadRows()
        }
       
    }
    
}
