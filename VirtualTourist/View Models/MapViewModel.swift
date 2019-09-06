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
    
    public var dataManager: DataManager
    
    weak var fetcherDelegate: PinDataServiceProtocol?
    
    init(fetcherDelegate: PinDataServiceProtocol, dataManager: DataManager) {
        self.fetcherDelegate = fetcherDelegate
        self.dataManager = dataManager
    }
    
    public func fetchSavedPins() {
        guard let savedPins = dataManager.fetchEntities(entityName: "Pin") as? [Pin] else {
            return
        }
        fetcherDelegate?.savedPinsFetched(pins: savedPins)
    }

    public func savePin(longitude: Float, latitude: Float) {
        let attributes = ["longitude": longitude,
                          "latitude" : latitude
                          ]
        dataManager.savePin(attributes: attributes)
    }
    
    public func getDetailView(longitude: Float, latitude: Float)-> LocationDetailViewModel? {
        guard let pin = findPin(longitude: longitude, latitude: latitude) else { return nil}
        let vm = LocationDetailViewModel(pin: pin, dataManager: dataManager)
        return vm
    }
    
    private func findPin(longitude: Float, latitude: Float)-> Pin? {
        guard let pins = dataManager.findPin(latitude: latitude, longitude: longitude), pins.count > 0 else {
            print("No pins with \(latitude) \(longitude) found")
            return nil
        }
        print("Found \(pins.count) pins with  \(latitude) \(longitude)")
        return pins.first
    }

    public func deletePin(longitude: Float, latitude: Float) {
        guard let pin = findPin(longitude: longitude, latitude: latitude) else { return }
        dataManager.deleteEntity(entity: pin)
        
        dataManager.deleteEntity(entity: pin)
        fetcherDelegate?.reloadData()
    }
}
