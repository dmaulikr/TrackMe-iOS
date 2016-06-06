//
//  ImportController.swift
//  TrackMe
//
//  Created by HaoBoji on 1/06/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class ImportController: UITableViewController {

    var delegate: ImportLocationsDelegate?
    var managedObjectContext: NSManagedObjectContext
    var filePaths: [NSURL]?
    var importMessage: String

    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        self.importMessage = ""
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Import Data"
        filePaths = loadFileURLs()
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
        return filePaths!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImportCell", forIndexPath: indexPath) as! ImportCell
        cell.fileName.text = filePaths![indexPath.row].lastPathComponent
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // For import
        let filePath = filePaths![indexPath.row]
        activateImportDialog(filePath)
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return importMessage
    }

    func activateImportDialog(filePath: NSURL) {
        let importDialog = UIAlertController(
            title: "Import Locations",
            message: "Import from " + filePath.lastPathComponent!,
            preferredStyle: UIAlertControllerStyle.Alert)
        importDialog.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: nil))
        importDialog.addAction(UIAlertAction(
            title: "Confirm",
            style: UIAlertActionStyle.Default,
            handler: {
                (alert: UIAlertAction!) in
                self.delegate!.saveJsonToCoreData(filePath)
                self.navigationController!.popViewControllerAnimated(true)
            }))
        self.presentViewController(importDialog, animated: false, completion: nil)
    }

    func loadFileURLs() -> [NSURL] {
        // Get the documents folder url
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        // Filter directory contents
        var jsonFiles: [NSURL] = []
        do {
            let directoryUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            jsonFiles = directoryUrls.filter { $0.pathExtension == "json" }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return jsonFiles
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
