//
//  TrackMeTests.swift
//  TrackMeTests
//
//  Created by HaoBoji on 3/05/2016.
//  Copyright © 2016 HaoBoji. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TrackMe

class TrackMeTests: XCTestCase {

    var settingsController: SettingsController?

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        settingsController = storyboard.instantiateViewControllerWithIdentifier("SettingsController") as? SettingsController
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let invalidJson = documentsUrl.URLByAppendingPathComponent("invalid.json")
        XCTAssertFalse(settingsController!.saveJsonToCoreData(invalidJson))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
            let filePath = self.settingsController!.generateFilePath()
            let locations = self.settingsController!.fetchLocations()
            self.settingsController!.writeLocationToFile(locations, filePath: filePath)
        }
    }

}
