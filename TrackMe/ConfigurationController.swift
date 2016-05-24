//
//  SettingCellController.swift
//  TrackMe
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import CoreData

class ConfigurationController: UITableViewController {

    let DISTANCE_FILTER: Int = 1
    let DESIRED_ACCURACY: Int = 2
    let distanceFilters: [String] = ["None", "10 Metres", "20 Metres", "50 Metres", "100 Metres"]
    let desiredAccuracies: [String] = ["Best", "10 Metres", "20 Metres", "50 Metres", "100 Metres"]

    var managedObjectContext: NSManagedObjectContext
    var configuration: Configuration?
    var category: Int?

    required init?(coder aDecoder: NSCoder) {
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
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switch category! {
        case DISTANCE_FILTER:
            self.title = "Distance Filter"
            break
        case DESIRED_ACCURACY:
            self.title = "Desired Accuracy"
            break
        default:
            break
        }

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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch category! {
        case DISTANCE_FILTER:
            return distanceFilters.count
        case DESIRED_ACCURACY:
            return desiredAccuracies.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConfigurationCell", forIndexPath: indexPath) as! ConfigurationCell

        // Configure the cell...
        switch category! {
        case DISTANCE_FILTER:
            cell.lKey.text = distanceFilters[indexPath.row]
            if (indexPath.row == 0 && self.configuration!.distanceFilter == 0) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if (cell.lKey.text == configuration!.distanceFilter!.stringValue + " Metres") {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            break
        case DESIRED_ACCURACY:
            cell.lKey.text = desiredAccuracies[indexPath.row]
            if (indexPath.row == 0 && self.configuration!.desiredAccuracy == 0) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if (cell.lKey.text == configuration!.desiredAccuracy!.stringValue + " Metres") {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            break
        default:
            break
        }
        return cell
    }

    // On configuration selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch category! {
        case DISTANCE_FILTER:
            // Determine selected item and convert to double value
            if (distanceFilters[indexPath.row].containsString("Metres")) {
                let stringValue: String = distanceFilters[indexPath.row].stringByReplacingOccurrencesOfString(" Metres", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let distanceFilter: Double = Double(stringValue)!
                configuration!.distanceFilter = distanceFilter
            } else {
                configuration!.distanceFilter = 0
            }
            break
        case DESIRED_ACCURACY:
            // Determine selected item and convert to double value
            if (desiredAccuracies[indexPath.row].containsString("Metres")) {
                let stringValue: String = desiredAccuracies[indexPath.row].stringByReplacingOccurrencesOfString(" Metres", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let desiredAccuracy: Double = Double(stringValue)!
                configuration!.desiredAccuracy = desiredAccuracy
            } else {
                configuration!.desiredAccuracy = 0
            }
            break
        default:
            break
        }
        // Save configuration to coredata
        do {
            try configuration!.managedObjectContext?.save()
        } catch let error {
            print("Could not save Configuration \(error)")
        }
        // Refresh view
        self.tableView.reloadData()
        // Reload configuration
        LocationManager.shared.loadConfiguration()
    }

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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
