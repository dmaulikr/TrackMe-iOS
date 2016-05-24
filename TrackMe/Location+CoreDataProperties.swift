//
//  Location+CoreDataProperties.swift
//  
//
//  Created by HaoBoji on 12/05/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var timestamp: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var horizontalAccuracy: NSNumber?
    @NSManaged var verticalAccuracy: NSNumber?
    @NSManaged var speed: NSNumber?
    @NSManaged var altitude: NSNumber?

}
