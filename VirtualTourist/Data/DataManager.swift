//
//  DataManager.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 9/3/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
    func fetchEntities<T: NSManagedObject>(entityName: String) -> [T]? {
        var result: [T]?
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            result = try viewContext.fetch(fetchRequest) as? [T]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return result
    }
    
    
    func saveEntity<T: NSManagedObject>(entity: T.Type, with attributes: Dictionary<String, Any>) {
        let newEntity = T(context: viewContext)
        newEntity.setValuesForKeys(attributes)
        try? viewContext.save()
    }
}

extension DataManager{
    func autoSaveViewContext(interval: TimeInterval = 30) {
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
