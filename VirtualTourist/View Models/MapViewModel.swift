//
//  ViewModel.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 8/31/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol PinDataServiceProtocol: class {
    func savedPinsFetched(pins: [Pin])
    func reloadData()
}

class MapViewModel {
    
    // Initialization of class responsible for managing Core Data objects.
    public var dataManager: DataManager
    
    weak var fetcherDelegate: PinDataServiceProtocol?
    
    init(fetcherDelegate: PinDataServiceProtocol, dataManager: DataManager) {
        self.fetcherDelegate = fetcherDelegate
        self.dataManager = dataManager
    }
    
    // MARK: Fetch saved photos.
    public func fetchSavedPins() {
        guard let savedPins = dataManager.fetchEntities(entityName: "Pin") as? [Pin] else {
            return
        }
        fetcherDelegate?.savedPinsFetched(pins: savedPins)
    }

    // MARK: Save a pin.
    public func savePin(longitude: Float, latitude: Float) {
        let attributes = ["longitude": longitude,
                          "latitude" : latitude ]
        dataManager.savePin(attributes: attributes)
    }
    
    
    // MARK: Detail view of a pin.
    
    // This function is responsible for initialization a view model with parameters of Pin entity to feed a PhotoAlbumVC with required data.
    public func getDetailView(longitude: Float, latitude: Float)-> LocationDetailViewModel? {
        
        // Based on known latitude/longitude, it is possible to find a Pin entity.
        guard let pin = findPin(longitude: longitude, latitude: latitude) else { return nil}
        
        // Initialization of a view model with parameters of current Pin entity.
        let vm = LocationDetailViewModel(pin: pin, dataManager: dataManager)
        return vm
    }
    
    // MARK: Find a pin.
    private func findPin(longitude: Float, latitude: Float)-> Pin? {
        
        guard let pins = dataManager.findPin(latitude: latitude, longitude: longitude), pins.count > 0 else {
            print("No pins with \(latitude) \(longitude) found")
            return nil
        }
        print("Found \(pins.count) pins with  \(latitude) \(longitude)")
        return pins.first
    }

    
    // MARK: Delete a pin.
    public func deletePin(longitude: Float, latitude: Float) {
        guard let pin = findPin(longitude: longitude, latitude: latitude) else { return }
        dataManager.deleteEntity(entity: pin)
        
        dataManager.deleteEntity(entity: pin)
        fetcherDelegate?.reloadData()
    }
}
