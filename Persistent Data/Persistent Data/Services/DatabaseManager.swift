//
//  DatabaseManager.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-04.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import CoreData

class DatabaseManager {
    static let shared = DatabaseManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "learn-swift-winnipeg")
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: - Report error
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
}

// MARK: - Coredata management

extension DatabaseManager {
    
    /// Errors should be handled out of the database manager
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        
        if context.hasChanges { try context.save() }
    }
    
    /// Convenient function for removing objects
    
    func delete(_ object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
    }
}
