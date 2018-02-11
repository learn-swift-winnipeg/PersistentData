//
//  SimpleData.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-05.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import CoreData

class Simple: NSManagedObject {
    
    static let entityName = "Simple"
    
    @NSManaged var createdAt: Date
    @NSManaged var guid: String
}
