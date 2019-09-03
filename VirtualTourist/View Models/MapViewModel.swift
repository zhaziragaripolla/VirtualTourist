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
}

protocol AlertShowerProtocol: class {
    func showAlert(with message: String)
}

class MapViewModel {
    
    public var dataManager: DataManager?
    
    weak var fetcherDelegate: PinDataServiceProtocol?
    weak var alertDelegate: AlertShowerProtocol?
    
    init(fetcherDelegate: PinDataServiceProtocol, alertDelegate: AlertShowerProtocol ) {
        self.fetcherDelegate = fetcherDelegate
        self.alertDelegate = alertDelegate
      
    }
    
    public func fetchSavedPins() {
        guard let savedPins = dataManager?.fetchEntities(entityName: "Pin") as? [Pin] else {
            alertDelegate?.showAlert(with: "No saved pins found!")
            return
        }
        print("Found \(savedPins.count) pins")
        fetcherDelegate?.savedPinsFetched(pins: savedPins)
    }

    public func savePin(longitude: Float, latitude: Float) {
        let attributes = ["longitude": longitude,
                          "latitude" : latitude
                          ]
        print("saved")
        dataManager?.saveEntity(entity: Pin.self, with: attributes)
    }
    
    public func getDetailView(longitude: Float, latitude: Float)-> LocationDetailViewModel? {
        guard let pins = dataManager?.findEntity(entityName: "Pin", lat: latitude, long: longitude) as? [Pin] else {
                print("No pins with \(latitude) \(longitude) found")
                return nil
        }
        print("Found \(pins.count) pins with  \(latitude) \(longitude)")
        
        let vm = LocationDetailViewModel()
        vm.dataManager = dataManager
        vm.currentPin = pins.first
        return vm
    }
}
