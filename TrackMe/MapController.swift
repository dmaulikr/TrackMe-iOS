//
//  FirstViewController.swift
//  TrackMe
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class MapController: UIViewController, GMSMapViewDelegate {

    @IBOutlet var floatingBar: UINavigationItem!

    var managedObjectContext: NSManagedObjectContext
    var lastKnownLocation: CLLocation?
    var mapView: GMSMapView?
    var selectedDate: NSDate?
    let dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    let circleBlue: UIImageView
    let circleSky: UIImageView
    let circleRed: UIImageView
    let circleOrange: UIImageView
    let circleGreen: UIImageView
    let circleGray: UIImageView

    required init?(coder aDecoder: NSCoder) {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let circleImage = UIImage(named: "circle")!.imageWithRenderingMode(.AlwaysTemplate)
        circleRed = UIImageView(image: circleImage)
        circleRed.tintColor = UIColor(red: 0.74, green: 0.21, blue: 0.18, alpha: 1.0)
        circleBlue = UIImageView(image: circleImage)
        circleBlue.tintColor = UIColor(red: 0.00, green: 0.27, blue: 0.80, alpha: 1.0)
        circleSky = UIImageView(image: circleImage)
        circleSky.tintColor = UIColor(red: 0.00, green: 0.53, blue: 0.80, alpha: 1.0)
        circleOrange = UIImageView(image: circleImage)
        circleOrange.tintColor = UIColor(red: 0.97, green: 0.58, blue: 0.02, alpha: 1.0)
        circleGreen = UIImageView(image: circleImage)
        circleGreen.tintColor = UIColor(red: 0.32, green: 0.64, blue: 0.32, alpha: 1.0)
        circleGray = UIImageView(image: circleImage)
        circleGray.tintColor = UIColor.grayColor()
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lastKnownLocation = LocationManager.shared.getLastLocation()
        var camera: GMSCameraPosition
        if (lastKnownLocation == nil) {
            camera = GMSCameraPosition.cameraWithLatitude(-37.8773961978499, longitude: 145.045122108377, zoom: 5)
        } else {
            camera = GMSCameraPosition.cameraWithLatitude(lastKnownLocation!.coordinate.latitude, longitude: lastKnownLocation!.coordinate.longitude, zoom: 14)
        }
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: camera)
        mapView!.padding = UIEdgeInsets(top: 80.0, left: 0.0, bottom: 50.0, right: 0.0)
        mapView!.myLocationEnabled = true
        mapView!.settings.compassButton = true
        mapView!.settings.myLocationButton = true
        mapView!.settings.indoorPicker = true
        self.view.insertSubview(mapView!, atIndex: 0)
        mapView!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        floatingBar.title = "All"
        let locations = fetchLocations(nil)
        updateMapViewByLocations(locations)
    }

    func fetchLocations(let byDate: NSDate?) -> NSArray {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        let predicate: NSPredicate
        if (byDate == nil) {
            predicate = NSPredicate(format: "(speed > 0)")
        } else {
            let nextDate = byDate!.dateByAddingTimeInterval(60 * 60 * 24)
            predicate = NSPredicate(format: "(speed > 0) AND (timestamp > %@) AND (timestamp < %@)", byDate!, nextDate)
        }
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = predicate
        var locations = NSArray?()
        do {
            locations = try self.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return locations!
    }

    @IBAction func pickDate(sender: UIBarButtonItem) {
        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .Date) {
            (date) -> Void in
            self.floatingBar.title = self.dateFormatter.stringFromDate(date)
            self.selectedDate = self.dateFormatter.dateFromString(self.floatingBar.title!)
            let locations = self.fetchLocations(self.selectedDate)
            self.updateMapViewByLocations(locations)
        }
    }

    @IBAction func share(sender: UIBarButtonItem) {
        let bounds = UIScreen.mainScreen().bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    func updateMapViewByLocations(locations: NSArray) {
        mapView!.clear()
        // Limit the number of locations that are about to display
        let n: Int = locations.count / 1000 + 1
        for i in 0 ..< locations.count / n {
            let location: Location = locations[i * n] as! Location
            let circleCenter = CLLocationCoordinate2D(latitude: location.latitude as! CLLocationDegrees, longitude: location.longitude as! CLLocationDegrees)
            let marker = GMSMarker(position: circleCenter)
            if (location.speed!.doubleValue < 1) {
                marker.iconView = circleRed
            } else if (location.speed!.doubleValue < 4) {
                marker.iconView = circleRed
            } else if (location.speed!.doubleValue < 13) {
                marker.iconView = circleOrange
            } else if (location.speed!.doubleValue < 20) {
                marker.iconView = circleGreen
            } else if (location.speed!.doubleValue < 25) {
                marker.iconView = circleSky
            } else {
                marker.iconView = circleBlue
            }
            if (floatingBar.title == "All") {
                marker.title = dateFormatter.stringFromDate(location.timestamp!)
            } else {
                marker.title = timeFormatter.stringFromDate(location.timestamp!)
            }
            marker.map = mapView
        }
    }

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        if (floatingBar.title != "All") {
            return
        }
        self.floatingBar.title = marker.title
        self.selectedDate = self.dateFormatter.dateFromString(self.floatingBar.title!)
        let locations = self.fetchLocations(self.selectedDate)
        self.updateMapViewByLocations(locations)
    }
}
