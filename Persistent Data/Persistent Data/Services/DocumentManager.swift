//
//  DocumentManager.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-20.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import UIKit

class DocumentManager {
    static let shared = DocumentManager()
    
    lazy var documentManager = DocumentManager.shared
    
    var isRunningTransactions = false
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var storageUrl: URL = {
        return self.applicationDocumentsDirectory.appendingPathComponent("storage", isDirectory: true)
    }()
}

struct AnotherSimpleData: Codable {
    var createdOn: Date
    var guid: String
}

typealias FileDatabase = [AnotherSimpleData]

extension DocumentManager {
    
    func getFileDatabase() -> FileDatabase {
        do {
            let db = try Data.init(contentsOf: storageUrl)
            
            let decoder = PropertyListDecoder()
            let decoded = try decoder.decode(FileDatabase.self, from: db)
            
            return decoded
        } catch {
            print("Could not retrieve database: \(error)")
            return []
        }
    }
    
    func addNewEntry(_ entry: AnotherSimpleData) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        var database = getFileDatabase()
        database.append(entry)
        
        do {
            let data = try encoder.encode(database)
            try data.write(to: storageUrl)
        } catch {
            // TODO: Report error
            print("failed to write entry into file: \(error)")
        }
    }
    
    func bulkGeneration() {
        
        DispatchQueue.global(qos: .background).async {
            while self.isRunningTransactions {
                let anotherSimpleData = AnotherSimpleData(createdOn: Date(), guid: UUID().uuidString)
                
                self.documentManager.addNewEntry(anotherSimpleData)
                NotificationCenter.default.post(name: NSNotification.Name("transaction-performed"), object: nil)
            }
        }
    }
}
