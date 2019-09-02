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

class PinDataService {
    var pins = [Pin]()
    
    init() {
        fetchLocations()
    }
    
    private func fetchLocations() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Pin")
        
        do {
            pins = try managedContext.fetch(fetchRequest) as! [Pin]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func save(lat: Float, long: Float) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Pin",
                                       in: managedContext)!
        
        let pin = NSManagedObject(entity: entity,
                                  insertInto: managedContext)
        
        pin.setValue(lat, forKeyPath: "latitude")
        pin.setValue(long, forKeyPath: "longitude")
      
        do {
            try managedContext.save()
            pins.append(pin as! Pin)
            print("saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        catch {
            print(error)
        }
    }
}
