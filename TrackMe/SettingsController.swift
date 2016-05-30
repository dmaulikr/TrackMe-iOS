//
//  SettingsController.swift
//  TrackMe
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import ObjectMapper

class SettingsController: UITableViewController {

    @IBOutlet var isUpdating: UISwitch!

    var managedObjectContext: NSManagedObjectContext

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        super.init(coder: aDecoder)
        writeLocationToFile(fetchLocations())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isUpdating.on = LocationManager.shared.on

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            // Track Me
        case 0:
            return 1
            // Configuration
        case 1:
            return 2
            // Data
        case 2:
            return 2
        default:
            return 0
        }
    }

    func fetchLocations() -> NSArray {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
        var locations = NSArray?()
        do {
            locations = try self.managedObjectContext.executeFetchRequest(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return locations!
    }

    func writeLocationToFile(locations: NSArray) {
        // File name and path
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let fileName = formatter.stringFromDate(NSDate()) + "_MyTrack.json"
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        let filePath = documentsDirectoryPath.URLByAppendingPathComponent(fileName)
        // Prepare json object
        let sample: Location = locations[0] as! Location
        let test: [String: AnyObject] = ["aa": sample.altitude!, "bb": sample.latitude!]
        let array = NSMutableArray()
        array.addObject(test)
        array.addObject(test)
        let a = NSJSONSerialization.isValidJSONObject(array)
        let json = JSON(locations)
        let str = json.description
        let data = str.dataUsingEncoding(NSUTF8StringEncoding)!
        NSFileManager.defaultManager().createFileAtPath(filePath.path!, contents: nil, attributes: nil)
        let file = NSFileHandle(forWritingAtPath: filePath.path!)
        if (file != nil) {
            file!.writeData(data)
        }
//        do {
//            let file = try NSFileHandle(forWritingToURL: filePath)
//            file.writeData(data)
//        } catch {
//            print(error)
//        }
    }

    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

     // Configure the cell...

     return cell
     }
     */

    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "DistanceFilter":
            if let destinationVC = segue.destinationViewController as? ConfigurationController {
                destinationVC.category = destinationVC.DISTANCE_FILTER
            }
            break
        case "DesiredAccuracy":
            if let destinationVC = segue.destinationViewController as? ConfigurationController {
                destinationVC.category = destinationVC.DESIRED_ACCURACY
            }
            break
        default:
            break
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func sTrackMe(sender: UISwitch) {
        if (sender.on) {
            LocationManager.shared.start()
        } else {
            LocationManager.shared.stop()
        }
    }
}
