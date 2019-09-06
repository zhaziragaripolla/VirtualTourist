//
//  DataManager.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/4/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    init() {
        persistentContainer = NSPersistentContainer(name: "VirtualTourist")
        load()
    }
    
    private let persistentContainer: NSPersistentContainer
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func load() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
        }
    }
    
    public func savePhoto(with pin: Pin, attributes: Dictionary<String, Any>){
        let newPhoto = Photo(context: viewContext)
        newPhoto.setValuesForKeys(attributes)
        newPhoto.pin = pin
        try? viewContext.save()
    }
    
    public func updatePhoto(photo: Photo, new attributes: Dictionary<String, Any>) {
        photo.setValuesForKeys(attributes)
        try? viewContext.save()
    }
    
    public func savePin(attributes: Dictionary<String, Any>) {
        let newPin = Pin(context: viewContext)
        newPin.setValuesForKeys(attributes)
        try? viewContext.save()
    }
    
    public func fetchEntities<T>(entityName: String)-> [T]? where T : NSManagedObject{
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        var result: [T]?
        do {
            result = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return result
    }
    
    public func deleteEntity<T>(entity: T) where T : NSManagedObject {
        viewContext.delete(entity)
        try? viewContext.save()
    }
    
    public func findPin(latitude: Float, longitude: Float)-> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        let predicate = NSPredicate(format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", latitude - 1, latitude + 1, longitude - 1, longitude + 1)
        fetchRequest.predicate = predicate
        var result: [Pin]?
        do {
            result = try viewContext.fetch(fetchRequest) as? [Pin]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return result
    }

    
    private func autoSaveViewContext(interval: TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    
}
