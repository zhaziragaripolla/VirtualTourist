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
    func reloadData()
}

class LocationDetailViewModel {
    
    public var currentPin: Pin!
    public var dataManager: DataManager!
    private var currentPage: Int = 1
    var images: [UIImage] = [] {
        didSet {
            delegate?.reloadData()
        }
    }
    
    let networkManager = NetworkManager()
    
    weak var delegate: LocationDetailViewModelProtocol?
    
//    init(delegate: LocationDetailViewModelProtocol) {
//        self.delegate = delegate
//    }
    
    func searchPhotos() {
        
        if let photoSet = currentPin.photo, let photos = photoSet.allObjects as? [SavedPhoto], photos.count > 0 {
            photos.forEach({
                if let data = $0.image, let image = UIImage(data: data) {
                    images.append(image)
                }
            })
            print("Found \(photos.count) saved photos associated with pin)")
        }
        else {
            networkManager.searchPhotos(page: currentPage, lat: currentPin.latitude, long: currentPin.longitude, completion: {[weak self] photos in
                guard let photos = photos else {
                    print("No photos")
                    return
                }
                photos.forEach({
                    self?.downloadImage(for: $0)
                })
                self?.delegate?.reloadData()
                print("Fetched \(photos.count) photos")
            })
        }
        
    }
    
    func downloadImage(for photo: Photo) {
        networkManager.getImage(photo: photo, completion: { [weak self] data in
            if let unwrappedData = data,
                let image = UIImage(data: unwrappedData)?.pngData() {
                let savedPhoto = SavedPhoto(context: (self?.dataManager.viewContext)!)
                savedPhoto.image = image
                try? self?.dataManager.viewContext.save()
                self?.currentPin.addToPhoto(savedPhoto)
                print("Image added to core data")
//                self?.dataManager.saveEntity(entity: SavedPhoto.self, with: ["image" : image])
//                currentPin.addToPhoto()
                self?.images.append(UIImage(data: unwrappedData)!)
            }
        })
    }
    
}
