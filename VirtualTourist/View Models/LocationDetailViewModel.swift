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
    
    // Initializing a class responsible for managing a Core Data.
    public var dataManager: DataManager
    
    // Boolean variable for managing 2 datasources: Core data and Flickr API
    public var isUsingSavedPhotos: Bool
    
    private var currentPage: Int
    private var totalPages: Int
    
    public var flickrPhotos: [FlickrPhoto] = []
    public var savedPhotos: [Photo] = []
    
    // Array is used for storing images for further persisting.
    private var images: [UIImage] = []
    
    // Initializing a class responsible for Network calls.
    private let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
    init(pin: Pin, dataManager: DataManager) {
        
        currentPin = pin
        self.dataManager = dataManager
        
        totalPages = 1
        isUsingSavedPhotos = false
        currentPage = 1
    }
    
    // This function only one when is called when PhotoAlbumVC is loaded.
    // It defines which datasource to use based on count of related enitites of current pin.
    public func loadSavedPhotos() {
        
        if let photoSet = currentPin.photo,
            let photos = photoSet.allObjects as? [Photo],
            photos.count > 0 {
            
            // If there are some persisted images, use them as datasource.
            savedPhotos = photos
            isUsingSavedPhotos = true
            delegate?.reloadRows()
        }
        else {
            
            // Otherwise, fetch new photos from Flickr API.
            isUsingSavedPhotos = false
            searchPhotos()
        }
        
    }
    
    public func downloadNewPhotos(){
        
        // The page for url request is taken randomly in order to show different images.
        currentPage = Int.random(in: 1...totalPages)
        
        // In case of replacing existing photos with a new ones, it is required to delete all old entities.
        if isUsingSavedPhotos {
            
            isUsingSavedPhotos = !isUsingSavedPhotos
            
            // Deleting saved images from persistent store.
            savedPhotos.forEach({
                dataManager.deleteEntity(entity: $0)
            })
        }
     
        searchPhotos()
    }
    
    // Make a network request for searching photos with parameters of current pin.
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
    
    // This function is called only once when the PhotoAlbumVC is about to disappear.
    public func savePhotos(){
        
        // Converting images into Data object to save them as a new entities related to defined pin.
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
