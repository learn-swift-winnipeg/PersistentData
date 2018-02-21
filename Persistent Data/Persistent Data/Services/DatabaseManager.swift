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
    
    var isRunningTransactions = false
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "database")
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
    
    @objc func saveContext() throws {
        let context = persistentContainer.viewContext
        
        if context.hasChanges { try context.save() }
    }
    
    /// Convenient function for removing objects
    
    func delete(_ object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
    }
}

// MARK: - Simple data

extension DatabaseManager {
    func bulkGeneration() {
        
        let privateMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMoc.parent = self.persistentContainer.viewContext
        
        privateMoc.perform {
            while self.isRunningTransactions {
                let entity = NSEntityDescription.insertNewObject(forEntityName: Simple.entityName, into: privateMoc) as! Simple
                entity.guid = UUID().uuidString
                entity.createdAt = Date()
                
                do {
                    try privateMoc.save()
                    NotificationCenter.default.post(name: NSNotification.Name("transaction-performed"), object: nil)
                    
                    self.persistentContainer.viewContext.performAndWait {
                        do {
                            try self.saveContext()
                        } catch {
                            print("Could not save main context while bullk inserting: \(error)")
                        }
                    }
                    
                } catch {
                    print("Could not save private context while bulk inserting: \(error)")
                }
            }
        }
    }
}
