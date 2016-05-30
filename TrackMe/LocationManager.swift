//
//  LocationManager.swift
//  TrackMe
//
//  Created by HaoBoji on 4/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

public class LocationManager: NSObject, CLLocationManagerDelegate {

    private let manager: CLLocationManager
    private let sigManager: CLLocationManager
    public var on: Bool
    var managedObjectContext: NSManagedObjectContext
    var configuration: Configuration?
    var deferringUpdates: Bool

    // static instance
    public static let shared = LocationManager()

    private override init() {
        on = true
        deferringUpdates = false
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Configuration", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        var result = NSArray?()
        do {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            if (result!.count == 0) {
                self.configuration = Configuration.init(entity: NSEntityDescription.entityForName("Configuration", inManagedObjectContext: self.managedObjectContext)!, insertIntoManagedObjectContext: self.managedObjectContext)
            } else {
                self.configuration = result![0] as? Configuration
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        // Initialize manager
        self.manager = CLLocationManager()
        // Background update
        self.manager.activityType = CLActivityType.Fitness
        self.manager.allowsBackgroundLocationUpdates = true
        self.manager.requestAlwaysAuthorization()
        self.sigManager = CLLocationManager()
        sigManager.startMonitoringSignificantLocationChanges()
        super.init()
        // Set configuration
        loadConfiguration()
        self.manager.delegate = self
        self.sigManager.delegate = self
    }

    public func start() {
        on = true
        manager.startUpdatingLocation()
        if (!deferringUpdates) {
            manager.allowDeferredLocationUpdatesUntilTraveled(100, timeout: 30)
            deferringUpdates = true;
        }
    }

    public func stop() {
        on = false
        manager.stopUpdatingLocation()
    }

    public func loadConfiguration() {
        // Set configuration
        if (configuration!.desiredAccuracy == 0) {
            self.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        } else {
            self.manager.desiredAccuracy = configuration!.desiredAccuracy!.doubleValue
        }
        if (configuration!.distanceFilter == 0) {
            self.manager.distanceFilter = kCLDistanceFilterNone
        } else {
            self.manager.distanceFilter = configuration!.distanceFilter!.doubleValue
        }
    }

    public func getLastLocation() -> CLLocation? {
        return manager.location
    }

    // MARK: - CLLocationManagerDelegate
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for location in locations {
            let newLocation: Location = (NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.managedObjectContext) as? Location)!
            newLocation.timestamp = location.timestamp
            newLocation.latitude = location.coordinate.latitude
            newLocation.longitude = location.coordinate.longitude
            newLocation.altitude = location.altitude
            newLocation.horizontalAccuracy = location.horizontalAccuracy
            newLocation.verticalAccuracy = location.verticalAccuracy
            newLocation.speed = location.speed
            print(newLocation.timestamp)
            do {
                try newLocation.managedObjectContext!.save()
            } catch let error {
                print("Could not save Location \(error)")
            }
        }
    }

    public func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        // Stop deferring updates
        self.deferringUpdates = false
        // Adjust for the next goal
    }

    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}
