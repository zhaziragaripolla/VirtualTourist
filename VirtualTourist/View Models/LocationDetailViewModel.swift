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
    
    public var currentPin: Pin
    public var dataManager: DataManager
    
    // Boolean variable for managing 2 datasources: Core data and Flickr API
    public var isUsingSavedPhotos: Bool
    
    private var currentPage: Int
    private var totalPages: Int
    
    public var flickrPhotos: [FlickrPhoto] = []
    public var savedPhotos: [Photo] = []
    private var images: [UIImage] = []
    
    private let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
    init(pin: Pin, dataManager: DataManager) {
        
        currentPin = pin
        self.dataManager = dataManager
        
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
    
    public func downloadNewPhotos(){
        
        currentPage = Int.random(in: 1...totalPages)
        
        if isUsingSavedPhotos {
            
            isUsingSavedPhotos = !isUsingSavedPhotos
            
            // Deleting saved images from persistent store
            savedPhotos.forEach({
                dataManager.deleteEntity(entity: $0)
            })
        }
     
        searchPhotos()
    }
    
    private func searchPhotos(){
        clearData()
        networkManager.searchPhotos(page: currentPage, lat: currentPin.latitude, long: currentPin.longitude, completion: {[weak self] response, error  in
            if let response = response, response.photo.count > 0  {
                self?.totalPages = response.pages
                self?.flickrPhotos = response.photo
                self?.delegate?.reloadRows()
            }
            else {
                 self?.delegate?.showAlert(message: "No photos found!")
            }
            
            if let error = error {
                self?.delegate?.showAlert(message: error)
            }
        })
        
    }
    
    public func downloadImage(for photo: FlickrPhoto, completion: @escaping (UIImage?)-> Void) {
        networkManager.getImage(photo: photo, completion: { data in
            if let unwrappedData = data, let image = UIImage(data: unwrappedData) {
                self.images.append(image)
                completion(image)
            }
        })
    }
    
    
    public func savePhotos(){
        images.forEach({
            self.dataManager.savePhoto(with: currentPin, attributes: ["image" : $0.pngData()!])
        })
    }
    
    public func deletePhoto(at index: Int) {
        if isUsingSavedPhotos {
            dataManager.deleteEntity(entity: self.savedPhotos[index])
            savedPhotos.remove(at: index)
        }
        else {
            flickrPhotos.remove(at: index)
            images.remove(at: index)
        }
        delegate?.reloadRows()
    }
    
    private func clearData(){
        images.removeAll()
        flickrPhotos.removeAll()
    }

}
