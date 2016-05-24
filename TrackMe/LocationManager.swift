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

    public let manager: CLLocationManager
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
        self.manager.activityType = CLActivityType.AutomotiveNavigation
        self.manager.allowsBackgroundLocationUpdates = true
        self.manager.requestAlwaysAuthorization()
        super.init()
        // Set configuration
        loadConfiguration()
        self.manager.delegate = self
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

    // =====================================     NSNotificationCenter Methods (App LifeCycle)  ====================//
    /********************************************************************************************************************
     METHOD NAME: appWillTerminate
     INPUT PARAMETERS: NSNotification object
     RETURNS: None

     OBSERVATIONS: The AppDelegate triggers this method when the App is about to be terminated (Removed from memory due to
     a crash or due to the user killing the app from the multitasking feature). This call causes the plugin to stop
     standard location services if running, and enable significant changes to re-start the app as soon as possible.
     ********************************************************************************************************************/
    func appWillTerminate() {

        // - Stop Location Updates
        self.manager.stopUpdatingLocation()

        // - Enables Significant Location Changes services to restart the app ASAP
        self.manager.startMonitoringSignificantLocationChanges()
    }
    /********************************************************************************************************************
     METHOD NAME: appIsRelaunched
     INPUT PARAMETERS: NSNotification object
     RETURNS: None

     OBSERVATIONS: This method is called by the AppDelegate when the app starts. This method will stop the significant
     change location updates and restart the standard location services if they where previously running (Checks saved
     NSUserDefaults)
     ********************************************************************************************************************/
    func appIsRelaunched() {

        // - Stops Significant Location Changes services when app is relaunched
        self.manager.stopMonitoringSignificantLocationChanges()

        self.start()
    }
}
