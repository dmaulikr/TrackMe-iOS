//
//  Configuration+CoreDataProperties.swift
//  TrackMe
//
//  Created by HaoBoji on 9/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Configuration {

    @NSManaged var desiredAccuracy: NSNumber?
    @NSManaged var distanceFilter: NSNumber?
}
