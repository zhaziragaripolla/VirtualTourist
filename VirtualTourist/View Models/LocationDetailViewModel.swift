//
//  LocationDetailViewModel.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/3/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit

protocol LocationDetailViewModelProtocol: class {
//    func fetchedImages(photos: [UIImage])
    func showAlert(message: String)
    func reloadRows()
}

class LocationDetailViewModel {
    
    public var currentPin: Pin!
//    private var photos: [SavedPhoto] = []
    public var dataManager: DataManager!
    
//    let rep = PhotoAlbumRepository<PhotoAlbum>()
    
    private var currentPage: Int = 1
    var images: [SavedPhoto] = [] {
        didSet {
            delegate?.reloadRows()
        }
    }
    
    private let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
//    init(delegate: LocationDetailViewModelProtocol) {
//        self.delegate = delegate
//    }
    
    public func loadSavedPhotos() {
        if let photoSet = currentPin.photo, let photos = photoSet.allObjects as? [SavedPhoto], photos.count > 0 {
            images = photos
            print("Found \(photos.count) saved photos associated with pin")
        }
        else {
            print("Loading photos from Flickr API")
            searchPhotos()
        }
        
    }
    
    private func searchPhotos(){
        networkManager.searchPhotos(page: currentPage, lat: currentPin.latitude, long: currentPin.longitude, completion: {[weak self] photos in
            guard let photos = photos else {
                print("No photos")
                return
            }
            photos.forEach({
                self?.downloadImage(for: $0)
                
            })
            self?.delegate?.reloadRows()
            print("Fetched \(photos.count) photos")
        })
    }
    
    private func downloadImage(for photo: Photo) {
       
        networkManager.getImage(photo: photo, completion: { [weak self] data in
            if let unwrappedData = data,
                let image = UIImage(data: unwrappedData),
                let pin = self?.currentPin {
                let savedImage = self?.dataManager.savePhoto(with: pin, attributes: ["image" : image.pngData()])
                self?.images.append(savedImage!)
                print("Image added to core data")
            }
        })
        
    }
    
    
    public  func deleteImages(at indices: [Int]) {
        for index in 0..<indices.count {
            images.remove(at: index)
            dataManager.deleteEntity(entity: images[index])
        }
        delegate?.reloadRows()
    }
    
//    private func findPhoto()-> [Pin]? {
//
//        guard let pins = dataManager?.findEntity(entityName: "Pin", latitude: latitude, longitude: longitude) as? [Pin], pins.count > 0 else {
//            print("No pins with \(latitude) \(longitude) found")
//            return nil
//        }
//        print("Found \(pins.count) pins with  \(latitude) \(longitude)")
//        return pins
//    }
    
}
